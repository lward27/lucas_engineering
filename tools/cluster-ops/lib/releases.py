"""One named-component release record around the established PHarness pin script."""
import hashlib
import json
import re
from pathlib import Path

from .common import OpsError, digest, now, run
from .connections import registry_read

COMPONENTS = ("runtime", "ui", "python-runner", "node-runner", "model-gateway", "eval-runner", "codex-host")
ACCEPT = "application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json"


def validate_manifest(manifest):
    if manifest.get("schema_version") != 1 or not re.fullmatch(r"[0-9a-f]{40}", manifest.get("source_revision", "")):
        raise OpsError("input", "Release record requires schema_version 1 and a complete source revision")
    images = manifest.get("images", {})
    if set(images) != set(COMPONENTS):
        raise OpsError("input", "Release record must contain exactly the seven PHarness components")
    for component, image in images.items():
        if image.get("repository") != "pharness-" + component or not re.fullmatch(r"sha256:[0-9a-f]{64}", image.get("digest", "")):
            raise OpsError("input", "Release image repository or immutable digest is invalid")
    bundle = manifest.get("native_bundle", {})
    if not bundle.get("path") or not re.fullmatch(r"sha256:[0-9a-f]{64}", bundle.get("digest", "")):
        raise OpsError("input", "Native bundle path and digest are required")


def verify_release(profile, manifest):
    validate_manifest(manifest)
    source = manifest["source_revision"]
    expected_source = profile.data["sources"]["pharness"]["repository"].removesuffix(".git")
    result = {"schema_version": 1, "observed_at": now(), "source_revision": source,
              "images": {}, "sbom_verified": False, "signature_verified": False,
              "provenance_attestation_verified": False, "layer_contents_verified": False}
    for component in COMPONENTS:
        image = manifest["images"][component]
        raw, _ = registry_read(profile, image["repository"], "manifests/" + image["digest"], ACCEPT)
        if digest(raw) != image["digest"]:
            raise OpsError("artifact_identity", f"Registry manifest digest mismatch for {component}")
        parsed = json.loads(raw)
        if "manifests" in parsed:
            raise OpsError("artifact_platform", "Expected a single AMD64 manifest, received an image index")
        config_digest = parsed["config"]["digest"]
        if not re.fullmatch(r"sha256:[0-9a-f]{64}", config_digest):
            raise OpsError("artifact_identity", "Invalid config digest")
        config_raw, _ = registry_read(profile, image["repository"], "blobs/" + config_digest)
        if digest(config_raw) != config_digest:
            raise OpsError("artifact_identity", f"Registry config digest mismatch for {component}")
        config = json.loads(config_raw)
        labels = config.get("config", {}).get("Labels", {})
        if (config.get("os"), config.get("architecture")) != ("linux", "amd64"):
            raise OpsError("artifact_platform", f"Unexpected image platform for {component}")
        if labels.get("org.opencontainers.image.revision") != source or labels.get("org.opencontainers.image.source", "").removesuffix(".git") != expected_source:
            raise OpsError("artifact_identity", f"OCI source labels do not match for {component}")
        result["images"][component] = {**image, "config_digest": config_digest,
                                         "platform": "linux/amd64", "source_verified": True}
    bundle = Path(manifest["native_bundle"]["path"]).expanduser()
    computed = hashlib.sha256()
    with bundle.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            computed.update(chunk)
    if "sha256:" + computed.hexdigest() != manifest["native_bundle"]["digest"]:
        raise OpsError("artifact_identity", "Native bundle digest mismatch")
    result["native_bundle"] = {"path": str(bundle), "digest": "sha256:" + computed.hexdigest(), "size_bytes": bundle.stat().st_size}
    result["status"] = "verified_artifacts"
    result["limitations"] = ["This check does not prove build test results, native bundle internal contents, GitOps reconciliation, or runtime acceptance."]
    return result


def pin_release(profile, manifest, repository):
    # The existing script remains authoritative for remote-head checks and pin edits.
    verified = verify_release(profile, manifest)
    root = Path(repository).resolve()
    if run(["git", "status", "--porcelain"], cwd=root).strip():
        raise OpsError("dirty_worktree", "Release pin worktree must be clean")
    remote = run(["git", "remote", "get-url", "origin"], cwd=root).decode().strip()
    if remote != profile.data["sources"]["pharness"]["repository"]:
        raise OpsError("repository_identity", "Release worktree has an unexpected remote")
    run([str(root / "scripts/pharness-release-pin.sh"), manifest["source_revision"],
         *[manifest["images"][c]["digest"] for c in COMPONENTS]], cwd=root, timeout=180)
    values = profile.data["sources"]["pharness"]["values"]
    chart = root / profile.data["sources"]["pharness"]["chart"]
    args = ["helm", "template", "pharness", str(chart), "--namespace", "pharness"]
    for value in values:
        args += ["-f", str(chart / value)]
    run(args, cwd=root, timeout=60)
    return {"status": "prepared_local_pin", "verified": verified,
            "worktree": str(root), "production_merge_approved": False,
            "next": "Review the local diff and validate the actual Argo overlay before the authorized release merge."}
