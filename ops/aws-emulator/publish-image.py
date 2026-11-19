#!/usr/bin/env python3
"""Publish this emulator image through the existing authenticated TLS gateway.

Uses the existing NodePort TLS gateway at 192.168.20.192:32443.
Reads only the named existing registry credential and CA into memory.
"""

import base64
import hashlib
import http.client
import json
from pathlib import Path
import socket
import ssl
import subprocess
import tarfile
import urllib.parse

ROOT = Path(__file__).resolve().parent
HOST = "registry-write-gateway.registry.svc.cluster.local"
REPO = "aws-emulator"
TAG = "1.0.385-20261115"
KUBECTL = ["kubectl", "--kubeconfig", "/home/wardl/.kube/config", "--context",
           "lucas_engineering", "--namespace", "tekton-pipelines"]


def secret(name, key):
    raw = subprocess.check_output(KUBECTL + ["get", "secret", name, "-o", "json"])
    return base64.b64decode(json.loads(raw)["data"][key])


def main():
    auths = json.loads(secret("lucas-registry-push", ".dockerconfigjson"))["auths"]
    auth = "Basic " + auths[HOST + ":8443"]["auth"]
    context = ssl.create_default_context(cadata=secret("registry-internal-ca", "ca.crt").decode())

    class GatewayConnection(http.client.HTTPSConnection):
        def connect(self):
            raw = socket.create_connection(("192.168.20.192", 32443), timeout=self.timeout)
            self.sock = context.wrap_socket(raw, server_hostname=HOST)

    def request(method, path, body=None, headers=None, allow_missing=False):
        conn = GatewayConnection(HOST, 8443, timeout=300)
        try:
            conn.request(method, path, body, headers={"Authorization": auth, **(headers or {})})
            response = conn.getresponse()
            data = response.read()
            if response.status >= 400 and not (allow_missing and response.status == 404):
                raise RuntimeError(f"Registry {method}: HTTP {response.status}")
            return response.status, dict(response.getheaders()), data
        finally:
            conn.close()

    with tarfile.open(ROOT / "image/.artifacts/aws-emulator.tar") as archive:
        def blob(digest):
            return archive.extractfile("blobs/sha256/" + digest.split(":", 1)[1])

        desc = json.load(archive.extractfile("index.json"))["manifests"][0]
        while True:
            manifest_bytes = blob(desc["digest"]).read()
            manifest = json.loads(manifest_bytes)
            if "layers" in manifest:
                break
            candidates = [m for m in manifest["manifests"]
                          if m.get("platform", {}).get("os") == "linux"
                          and m.get("platform", {}).get("architecture") == "amd64"]
            if len(candidates) != 1:
                raise RuntimeError("Expected one Linux AMD64 image")
            desc = candidates[0]
        digest = "sha256:" + hashlib.sha256(manifest_bytes).hexdigest()
        assert digest == desc["digest"]
        config = json.load(blob(manifest["config"]["digest"]))
        assert (config["os"], config["architecture"]) == ("linux", "amd64")
        labels = config["config"]["Labels"]
        assert labels["org.opencontainers.image.source"] == "https://github.com/aws/aws-emulator"
        assert labels["org.opencontainers.image.revision"] == "813af480bf7f16d5418b64e4f5644a74a7da11c5"
        for item in [manifest["config"], *manifest["layers"]]:
            status, _, _ = request("HEAD", f"/v2/{REPO}/blobs/{item['digest']}", allow_missing=True)
            if status != 404:
                continue
            _, headers, _ = request("POST", f"/v2/{REPO}/blobs/uploads/", b"", {"Content-Length": "0"})
            location = urllib.parse.urlsplit(next(v for k, v in headers.items() if k.lower() == "location"))
            path = location.path + ("?" + location.query + "&" if location.query else "?")
            path += urllib.parse.urlencode({"digest": item["digest"]})
            with blob(item["digest"]) as stream:
                request("PUT", path, stream, {"Content-Type": "application/octet-stream",
                                             "Content-Length": str(item["size"])})
            print("Uploaded", item["digest"], flush=True)
        media_type = desc.get("mediaType", manifest["mediaType"])
        request("PUT", f"/v2/{REPO}/manifests/{TAG}", manifest_bytes,
                {"Content-Type": media_type, "Content-Length": str(len(manifest_bytes))})
        _, _, actual = request("GET", f"/v2/{REPO}/manifests/{digest}",
                               headers={"Accept": media_type})
        assert hashlib.sha256(actual).hexdigest() == digest.split(":", 1)[1]
        receipt = {"image": f"registry.lucas.engineering/{REPO}@{digest}",
                   "tag": TAG, "digest": digest, "platform": "linux/amd64", "labels": labels}
        (ROOT / "image/IMAGE.json").write_text(json.dumps(receipt, indent=2) + "\n")
        print("Published and verified", receipt["image"])


if __name__ == "__main__":
    main()
