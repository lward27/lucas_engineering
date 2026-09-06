"""Verified registry TLS and private, reconnectable API reads."""
import base64
import http.client
import json
import os
import select
import socket
import ssl
import subprocess
import time
from pathlib import Path

from .common import OpsError, identifier


def response_bytes(response, limit=8 * 1024 * 1024):
    data = response.read(limit + 1)
    if len(data) > limit:
        raise OpsError("output_limit", "HTTP response exceeds the output limit")
    if response.status != 200:
        category = {401: "authentication", 403: "permission", 404: "not_found"}.get(response.status, "http")
        raise OpsError(category, f"HTTP request returned {response.status}")
    return data


class Tunnel:
    """Own one localhost-only port-forward; never kill another session's process."""
    def __init__(self, profile, namespace, resource, port):
        self.profile, self.namespace, self.resource, self.port = profile, namespace, resource, port
        self.process = None
        self.local_port = None
        self.connections = 0

    def connect(self):
        self.close()
        argv = self.profile.kubectl(["port-forward", self.resource, f":{self.port}",
                                    "--address=127.0.0.1", "--pod-running-timeout=15s"],
                                   self.namespace, streaming=True)
        self.process = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        deadline = time.monotonic() + 20
        output = b""
        while time.monotonic() < deadline:
            if self.process.poll() is not None:
                break
            ready, _, _ = select.select([self.process.stdout], [], [], min(0.2, max(0, deadline-time.monotonic())))
            if ready:
                output += os.read(self.process.stdout.fileno(), 1024)
                if len(output) > 4096:
                    break
                for line in output.decode(errors="replace").splitlines():
                    if line.startswith("Forwarding from 127.0.0.1:"):
                        self.local_port = int(line.split(":", 1)[1].split()[0])
                        self.connections += 1
                        return
        self.close()
        raise OpsError("transport", "Local tunnel did not become ready within 20 seconds")

    def request(self, method, path, headers=None, body=None, timeout=30):
        # Only reads may reconnect and retry; a lost POST response is uncertain.
        attempts = 2 if method == "GET" else 1
        for attempt in range(attempts):
            try:
                if self.process is None or self.process.poll() is not None:
                    self.connect()
                connection = http.client.HTTPConnection("127.0.0.1", self.local_port, timeout=timeout)
                try:
                    connection.request(method, path, body=body, headers=headers or {})
                    return response_bytes(connection.getresponse())
                finally:
                    connection.close()
            except (OSError, http.client.HTTPException) as error:
                self.close()
                if attempt + 1 == attempts:
                    raise OpsError("transport", "HTTP connection failed; write outcome may be uncertain") from error
            except OpsError as error:
                if error.category != "transport" or attempt + 1 == attempts:
                    raise
                self.close()

    def close(self):
        if self.process is not None:
            if self.process.poll() is None:
                self.process.terminate()
                try:
                    self.process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    self.process.kill()
                    self.process.wait(timeout=3)
            if self.process.stdout:
                self.process.stdout.close()
            self.process = None
        self.local_port = None


def secret_value(profile, reference):
    item = json.loads(profile.kubectl(["get", "secret/" + identifier(reference["name"]), "-o", "json"],
                                     reference["namespace"], private=True))
    try:
        value = base64.b64decode(item["data"][reference["key"]], validate=True).decode().strip()
        if reference.get("actor"):
            entries = dict(part.strip().split("=", 1) for part in value.split(",") if "=" in part)
            value = entries[reference["actor"]].strip()
        if not value:
            raise ValueError()
        return value
    except (KeyError, ValueError, UnicodeError) as error:
        raise OpsError("credential_format", "Named credential has no usable value for the configured identity") from error


class Pharness:
    def __init__(self, profile):
        self.profile = profile
        settings = profile.data["pharness"]
        self.tunnel = Tunnel(profile, settings["namespace"], settings["resource"], settings["port"])
        self.token = None

    def __enter__(self):
        self.token = secret_value(self.profile, self.profile.data["credentials"]["pharness"])
        return self

    def request(self, path, body=None, timeout=35):
        if not path.startswith("/api/") or ".." in path or "?" in path or "#" in path:
            raise OpsError("input", "Expected a bounded PHarness API path")
        headers = {"Authorization": "Bearer " + self.token}
        data = None
        if body is not None:
            headers["Content-Type"] = "application/json"
            data = json.dumps(body).encode()
        raw = self.tunnel.request("GET" if body is None else "POST", path, headers, data, timeout)
        # No credentials survive in evidence, even if a remote error echoes a header.
        raw = raw.decode().replace(self.token, "[redacted]")
        return json.loads(raw)

    def __exit__(self, *_):
        self.tunnel.close()
        self.token = None


def github_read(profile, credential, path):
    token = secret_value(profile, profile.data["credentials"][credential])
    connection = http.client.HTTPSConnection("api.github.com", timeout=20)
    try:
        connection.request("GET", path, headers={"Authorization": "Bearer " + token,
                           "User-Agent": "lucas-ops", "Accept": "application/vnd.github+json"})
        raw = response_bytes(connection.getresponse())
        return json.loads(raw.decode().replace(token, "[redacted]"))
    finally:
        connection.close()


def registry_read(profile, repository, suffix, accept=None):
    identifier(repository)
    settings = profile.data["registry"]
    context = ssl.create_default_context(cafile=str(Path(settings["ca_file"]).expanduser()))
    connection = http.client.HTTPSConnection(settings["hostname"], timeout=25, context=context)
    try:
        sock = socket.create_connection((settings["address"], settings["port"]), timeout=25)
        try:
            connection.sock = context.wrap_socket(sock, server_hostname=settings["hostname"])
        except BaseException:
            sock.close()
            raise
        connection.request("GET", "/v2/" + repository + "/" + suffix,
                           headers={"Accept": accept} if accept else {})
        response = connection.getresponse()
        data = response_bytes(response)
        return data, dict(response.headers)
    finally:
        connection.close()
