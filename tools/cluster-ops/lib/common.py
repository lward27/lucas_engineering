"""Small, bounded operator primitives. No shell evaluation or ambient context."""
import datetime
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path


class OpsError(Exception):
    def __init__(self, category, detail):
        super().__init__(detail)
        self.category = category


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def digest(data):
    return "sha256:" + hashlib.sha256(data).hexdigest()


def canonical(value):
    return (json.dumps(value, sort_keys=True, indent=2) + "\n").encode()


def identifier(value):
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,127}", value):
        raise OpsError("input", "Expected a single resource or operation identifier")
    return value


def run(argv, timeout=25, cwd=None, env=None, max_bytes=8 * 1024 * 1024, private=False):
    if private:
        # Kubernetes bounds individual Secret size; keep this response entirely in memory.
        try:
            result = subprocess.run(argv, capture_output=True, timeout=timeout, cwd=cwd, env=env)
        except (OSError, subprocess.TimeoutExpired) as error:
            raise OpsError("credential_read", "Private credential read did not complete") from error
        if result.returncode or len(result.stdout) > 2 * 1024 * 1024:
            raise OpsError("credential_read", "Private credential read failed or exceeded its limit")
        return result.stdout
    # File-backed capture prevents a large response from exhausting agent memory.
    with tempfile.TemporaryFile() as output, tempfile.TemporaryFile() as errors:
        try:
            result = subprocess.run(argv, stdout=output, stderr=errors, timeout=timeout,
                                    cwd=cwd, env=env, check=False)
        except subprocess.TimeoutExpired as error:
            raise OpsError("transport", "Command exceeded its bounded deadline") from error
        except FileNotFoundError as error:
            raise OpsError("missing_tool", f"Required executable is unavailable: {argv[0]}") from error
        output.seek(0)
        data = output.read(max_bytes + 1)
        if len(data) > max_bytes:
            raise OpsError("output_limit", "Command response exceeds the output limit")
        if result.returncode:
            errors.seek(0)
            message = errors.read(8192).decode(errors="replace").lower()
            category = "command"
            for marker, kind in [("unauthorized", "authentication"), ("forbidden", "permission"),
                                 ("notfound", "not_found"), ("not found", "not_found"),
                                 ("connection", "transport"), ("timeout", "transport")]:
                if marker in message:
                    category = kind
                    break
            # Never return subprocess stderr: credential-bearing commands can echo inputs.
            raise OpsError(category, f"{Path(argv[0]).name} failed with exit {result.returncode}")
        return data


def save(path, value, exclusive=False):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    data = canonical(value)
    if exclusive:
        try:
            fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        except FileExistsError as error:
            raise OpsError("existing_operation", "Record already exists; reconcile it instead of dispatching again") from error
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
    else:
        fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".record-")
        try:
            with os.fdopen(fd, "wb") as stream:
                stream.write(data)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, path)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
    return str(path)


class Profile:
    def __init__(self, path):
        self.path = Path(path).resolve()
        self.data = json.loads(self.path.read_text())
        if self.data.get("schema_version") != 1:
            raise OpsError("profile", "Unsupported operator profile schema")
        self.context = self.data["context"]
        self.kubeconfig = str(Path(self.data["kubeconfig"]).expanduser())
        self.verified = False

    def verify(self):
        server = run(["kubectl", "--kubeconfig", self.kubeconfig, "--context", self.context,
                      "--request-timeout=20s", "config", "view", "--minify",
                      "-o", "jsonpath={.clusters[0].cluster.server}"]).decode()
        if server != self.data["api_server"]:
            raise OpsError("cluster_identity", "Kubeconfig server differs from the selected profile")
        self.verified = True
        return {"context": self.context, "api_server": server, "profile_hash": digest(self.path.read_bytes())}

    def kubectl(self, args, namespace=None, timeout=25, streaming=False, private=False):
        if not self.verified:
            self.verify()
        command = ["kubectl", "--kubeconfig", self.kubeconfig, "--context", self.context,
                   "--request-timeout=" + ("0" if streaming else "20s")]
        if namespace:
            command += ["--namespace", identifier(namespace)]
        if streaming:
            return command + args
        return run(command + args, timeout=timeout, private=private)

    def get(self, resource, namespace=None):
        return json.loads(self.kubectl(["get", resource, "-o", "json"], namespace))
