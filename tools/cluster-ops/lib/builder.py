"""Use the existing Buildx builder and SSH route; never select a fallback."""
import os
import re
import socket
import ssl
import subprocess
import time
from pathlib import Path
from urllib.parse import urlsplit

from .common import OpsError, now, run


def inspect(profile):
    settings = profile.data["builder"]
    text = run(["docker", "--context", settings["docker_context"], "buildx", "inspect", settings["name"]], timeout=25).decode()
    endpoints = re.findall(r"(?m)^Endpoint:\s+(\S+)", text)
    if endpoints != [settings["client_endpoint"]] or not re.search(r"(?m)^Driver:\s+remote$", text):
        raise OpsError("builder_identity", "Existing Buildx builder has an unexpected driver or endpoint")
    endpoint = urlsplit(endpoints[0])
    if endpoint.scheme != "tcp" or endpoint.hostname != "127.0.0.1" or endpoint.port is None:
        raise OpsError("builder_identity", "Expected the reviewed localhost SSH route")
    tls = Path(settings["tls_directory"]).expanduser()
    context = ssl.create_default_context(cafile=str(tls / "ca.pem"))
    context.load_cert_chain(str(tls / "client-cert.pem"), str(tls / "client-key.pem"))
    with socket.create_connection((endpoint.hostname, endpoint.port), timeout=15) as connection:
        with context.wrap_socket(connection, server_hostname=settings["tls_servername"]) as secure:
            version = secure.version()
    if not re.search(r"(?m)^Platforms:.*\blinux/amd64(?:,|\s|$)", text):
        raise OpsError("builder_platform", "Linux AMD64 is not advertised by the selected worker")
    return {"builder": settings["name"], "docker_context": settings["docker_context"],
            "client_endpoint": endpoints[0], "tls_version": version,
            "platform_advertised": settings["platform"], "execution_test": "not_run"}


class BuilderConnection:
    def __init__(self, profile):
        self.profile, self.process = profile, None

    def __enter__(self):
        expected = self.profile.data["builder"]
        endpoint = urlsplit(expected["client_endpoint"])
        if endpoint.hostname != "127.0.0.1" or endpoint.scheme != "tcp" or not endpoint.port:
            raise OpsError("builder_identity", "Only the reviewed localhost SSH route is supported")
        try:
            with socket.create_connection(("127.0.0.1", endpoint.port), timeout=1):
                inspect(self.profile)
                return self
        except ConnectionRefusedError:
            pass
        argv = ["ssh", "-N", "-o", "BatchMode=yes", "-o", "ExitOnForwardFailure=yes",
                "-o", "ConnectTimeout=10", "-o", "ServerAliveInterval=15", "-o", "ServerAliveCountMax=2",
                "-L", f"127.0.0.1:{endpoint.port}:127.0.0.1:{expected['remote_port']}", expected["ssh_host"]]
        self.process = subprocess.Popen(argv, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        deadline = time.monotonic() + 15
        try:
            while time.monotonic() < deadline:
                if self.process.poll() is not None:
                    raise OpsError("transport", "SSH connection could not establish the selected BuildKit route")
                try:
                    with socket.create_connection(("127.0.0.1", endpoint.port), timeout=0.5):
                        inspect(self.profile)
                        return self
                except ConnectionRefusedError:
                    time.sleep(0.2)
            raise OpsError("transport", "BuildKit SSH route did not become ready")
        except BaseException:
            self.__exit__()
            raise

    def __exit__(self, *_):
        if self.process is not None and self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait(timeout=3)


def preflight(profile, repository, source):
    if not re.fullmatch(r"[0-9a-f]{40}", source):
        raise OpsError("input", "Use a complete merged source revision")
    root = Path(repository).resolve()
    remote = run(["git", "remote", "get-url", "origin"], cwd=root).decode().strip()
    if remote != profile.data["sources"]["pharness"]["repository"]:
        raise OpsError("repository_identity", "Build preflight requires the PHarness repository")
    environment = {**os.environ, "DOCKER_CONTEXT": profile.data["builder"]["docker_context"]}
    with BuilderConnection(profile):
        output = run([str(root / "scripts/pharness-build-local.sh"), "all", "--revision", source,
                      "--builder", profile.data["builder"]["name"], "--preflight-only"],
                     cwd=root, env=environment, timeout=180)
    # Parse the existing native script's final JSON receipt without copying log text.
    import json
    try:
        receipt = json.loads(output[output.rindex(b"\n{") + 1:])
    except (ValueError, KeyError) as error:
        raise OpsError("build_receipt", "Native build preflight did not return its expected receipt") from error
    if receipt.get("preflight") != "passed" or receipt.get("revision") != source or receipt.get("platform_execution") != "passed":
        raise OpsError("build_receipt", "Native build preflight did not prove the requested AMD64 execution")
    return {"observed_at": now(), "status": "passed_uncached_amd64_execution", "receipt": receipt,
            "image_pushes": 0, "cluster_mutations": []}
