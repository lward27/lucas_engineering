#!/usr/bin/env python3
"""Run a client with this emulator's credentials in memory and its verified CA.

Requires a running localhost port-forward. Never prints or stores credentials.
"""

import configparser
import json
import os
from pathlib import Path
import ssl
import subprocess
import sys
import urllib.request

ROOT = Path(__file__).resolve().parent
KUBECTL = [
    "kubectl", "--kubeconfig", "/home/wardl/.kube/config",
    "--context", "lucas_engineering", "--namespace", "aws-emulator",
]
ENDPOINT = "https://127.0.0.1:9297"


def main():
    if len(sys.argv) < 2:
        sys.exit("Usage: client.py <command> [args...] (for example: aws sts get-caller-identity)")
    pods = json.loads(subprocess.check_output(
        KUBECTL + ["get", "pods", "-l", "app.kubernetes.io/name=aws-emulator", "-o", "json"],
        text=True,
    ))["items"]
    ready = [pod for pod in pods if not pod["metadata"].get("deletionTimestamp")
             and any(c.get("type") == "Ready" and c.get("status") == "True"
                     for c in pod.get("status", {}).get("conditions", []))]
    if len(ready) != 1:
        sys.exit("Expected exactly one ready AWS Emulator Pod")
    pod = ready[0]
    remote = KUBECTL + ["exec", pod["metadata"]["name"], "--", "cat"]
    base = "/home/emulator/.aws/emulator/9297/"
    # Generated emulator keys are scoped to this run. Capture them privately;
    # never reuse the workstation's real AWS profile or persist these keys.
    credentials = configparser.RawConfigParser()
    credentials.read_string(subprocess.check_output(remote + [base + "emulator_credentials"], text=True))
    values = credentials["default"]
    ca = subprocess.check_output(remote + [base + "ca.pem"])
    runtime = ROOT / ".runtime" / pod["metadata"]["uid"]
    runtime.mkdir(parents=True, exist_ok=True, mode=0o700)
    cert = runtime / "ca.pem"
    cert.write_bytes(ca)
    cert.chmod(0o600)
    context = ssl.create_default_context(cafile=str(cert))
    # Ignore host proxy settings for the explicit loopback connection.
    opener = urllib.request.build_opener(
        urllib.request.ProxyHandler({}), urllib.request.HTTPSHandler(context=context))
    try:
        with opener.open(ENDPOINT + "/__admin/health", timeout=5) as response:
            if response.status != 200:
                raise RuntimeError("Emulator health check failed")
    except (OSError, urllib.error.URLError):
        sys.exit("Cannot reach the emulator with its current CA; start ops/aws-emulator/port-forward.sh")
    env = os.environ.copy()
    for name in ["AWS_PROFILE", "AWS_DEFAULT_PROFILE", "AWS_SESSION_TOKEN", "AWS_SECURITY_TOKEN",
                 "AWS_WEB_IDENTITY_TOKEN_FILE", "AWS_ROLE_ARN", "AWS_ROLE_SESSION_NAME",
                 "AWS_CONTAINER_CREDENTIALS_FULL_URI", "AWS_CONTAINER_CREDENTIALS_RELATIVE_URI"]:
        env.pop(name, None)
    # Per-service endpoint environment variables would override the global one.
    for name in list(env):
        if name.startswith("AWS_ENDPOINT_URL_"):
            env.pop(name)
    env.update({
        "AWS_ACCESS_KEY_ID": values["aws_access_key_id"],
        "AWS_SECRET_ACCESS_KEY": values["aws_secret_access_key"],
        "AWS_SHARED_CREDENTIALS_FILE": "/dev/null",
        "AWS_CONFIG_FILE": "/dev/null",
        "AWS_ENDPOINT_URL": ENDPOINT,
        "AWS_CA_BUNDLE": str(cert),
        "AWS_EC2_METADATA_DISABLED": "true",
        "AWS_DISABLE_HOST_PREFIX_INJECTION": "true",
        "AWS_IGNORE_CONFIGURED_ENDPOINT_URLS": "false",
        "AWS_REGION": "us-east-1",
        "AWS_DEFAULT_REGION": "us-east-1",
        "NODE_EXTRA_CA_CERTS": str(cert),
        "TF_VAR_emulator_ca_bundle": str(cert),
        "NO_PROXY": "127.0.0.1,localhost",
        "no_proxy": "127.0.0.1,localhost",
        "AWS_PAGER": "",
    })
    command = sys.argv[1:]
    if Path(command[0]).name == "aws":
        if any(arg == "--endpoint-url" or arg.startswith("--endpoint-url=") for arg in command[1:]):
            sys.exit("The helper sets --endpoint-url; omit that option from the AWS CLI command")
        command = [command[0], "--endpoint-url", ENDPOINT, *command[1:]]
    return subprocess.call(command, env=env)


if __name__ == "__main__":
    raise SystemExit(main())
