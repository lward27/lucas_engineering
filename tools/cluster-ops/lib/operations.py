"""Readiness and durable evaluation records; PHarness remains the workflow authority."""
import json
import re
import ssl
import time
from pathlib import Path

from .common import OpsError, canonical, digest, identifier, now, run, save
from .connections import Pharness, github_read, registry_read
from .builder import inspect as inspect_builder


def doctor(profile, credentials=False, builder=False):
    report = {"schema_version": 1, "observed_at": now(), "context": profile.context,
              "checks": [], "cluster_mutations": [], "limitations": [
                  "Readiness does not prove write permissions, builds, qualification, or application acceptance."]}

    def check(name, action):
        try:
            value = action()
            report["checks"].append({"name": name, "status": "passed", "observed": value})
        except (OpsError, OSError, ValueError, KeyError) as error:
            category = getattr(error, "category", "tls" if isinstance(error, ssl.SSLError)
                               else "transport" if isinstance(error, OSError) else "configuration")
            report["checks"].append({"name": name, "status": "failed",
                                     "category": category,
                                     "detail": str(error) if isinstance(error, OpsError) else type(error).__name__})

    check("cluster_identity", profile.verify)
    if report["checks"][0]["status"] != "passed":
        report["status"] = "blocked"
        return report
    def api_ready():
        if profile.kubectl(["get", "--raw=/readyz"]).decode().strip() != "ok":
            raise OpsError("readiness", "Kubernetes readyz is not ok")
        return "ok"
    check("kubernetes_ready", api_ready)
    for name in profile.data["pipelines"]:
        check("pipeline:" + name, lambda name=name: {
            "name": profile.get("pipeline/" + name, "tekton-pipelines")["metadata"]["name"]})

    def endpoint():
        expected = profile.data["builder"]
        item = profile.get("endpointslice/" + expected["endpoint_slice"], expected["service_namespace"])
        addresses = [a for e in item["endpoints"] for a in e["addresses"]]
        ports = [p["port"] for p in item["ports"]]
        if addresses != [expected["remote_address"]] or ports != [expected["remote_port"]]:
            raise OpsError("identity", "BuildKit EndpointSlice differs from the environment profile")
        return {"addresses": addresses, "ports": ports}
    check("buildkit_endpoint", endpoint)

    def argo():
        item = profile.get("application/" + profile.data["pharness"]["argo_application"], "argocd")
        expected = profile.data["sources"]["pharness"]
        source = item["spec"]["source"]
        if (source["repoURL"], source["path"], source.get("helm", {}).get("valueFiles", [])) != (
                expected["repository"], expected["chart"], expected["values"]):
            raise OpsError("identity", "Argo application uses unexpected source or Helm values")
        return {"source": source["repoURL"], "path": source["path"],
                "revision": item.get("status", {}).get("sync", {}).get("revision"),
                "sync": item.get("status", {}).get("sync", {}).get("status"),
                "health": item.get("status", {}).get("health", {}).get("status")}
    check("pharness_gitops_source", argo)
    check("registry_tls", lambda: {"catalog_access": bool(registry_read(profile, "pharness-runtime", "tags/list?n=1")[0]),
                                   "tls_hostname_verified": profile.data["registry"]["hostname"]})
    for key, reference in profile.data["credentials"].items():
        def permission(reference=reference):
            allowed = profile.kubectl(["auth", "can-i", "get", "secret/" + reference["name"]], reference["namespace"]).decode().strip()
            if allowed != "yes":
                raise OpsError("permission", "Cannot read the named credential")
            return {"namespace": reference["namespace"], "secret": reference["name"], "read_permitted": True}
        check("credential_reference:" + key, permission)
    if credentials:
        def ready():
            with Pharness(profile) as api:
                value = api.request("/api/system/readiness")
                if not value.get("platform_versions_match") or value.get("operational_mode") != "normal":
                    raise OpsError("readiness", "PHarness revisions differ or operational mode is not normal")
                return {key: value.get(key) for key in ["api_revision", "ui_revision", "platform_versions_match", "operational_mode"]}
        check("pharness_authentication", ready)
        for repository in profile.data["source_repositories"]:
            check("source_protection:" + repository, lambda repository=repository: {
                "repository": repository,
                "protection_readable": bool(github_read(profile, "source_writer", "/repos/" + repository + "/branches/main/protection"))})
        check("gitops_authentication", lambda: {
            "repository": github_read(profile, "gitops_writer", "/repos/" + profile.data["gitops_repository"])["full_name"]})
    if builder:
        check("builder_mtls_and_platform", lambda: inspect_builder(profile))
    report["status"] = "passed" if all(c["status"] == "passed" for c in report["checks"]) else "blocked"
    report["completed_at"] = now()
    return report


def start_evaluation(profile, api, request, policy, policy_revision, source, registry_hash, directory, operation_id):
    identifier(policy)
    identifier(policy_revision)
    identifier(operation_id)
    if not re.fullmatch(r"[0-9a-f]{40}", source) or not re.fullmatch(r"sha256:[0-9a-f]{64}", registry_hash):
        raise OpsError("input", "Source revision and registry hash must be complete immutable identities")
    if set(request) - {"actor", "reason", "config_hash", "attempts", "scope"}:
        raise OpsError("input", "Evaluation request contains unknown fields")
    if request.get("config_hash") != registry_hash or not request.get("actor") or not request.get("reason"):
        raise OpsError("input", "Reviewed request must contain actor, reason, and matching config_hash")
    scope = request.get("scope")
    if not isinstance(scope, dict) or scope.get("kind") not in ("diagnostic", "full_qualification"):
        raise OpsError("input", "Evaluation scope must be explicit")
    ready = api.request("/api/system/readiness")
    inference = ready.get("inference", {})
    if ready.get("api_revision") != source or ready.get("ui_revision") != source or not ready.get("platform_versions_match"):
        raise OpsError("stale_source", "Live source differs from the reviewed evaluation revision")
    if inference.get("api_registry_hash") != registry_hash or not inference.get("registry_aligned"):
        raise OpsError("stale_configuration", "Live inference registry differs from the reviewed configuration")
    if ready.get("operational_mode") != "normal":
        raise OpsError("paused", "PHarness is not in normal operational mode")
    path = Path(directory) / (operation_id + ".json")
    record = {"schema_version": 1, "kind": "pharness_evaluation", "context": profile.context,
              "operation_id": operation_id, "source_revision": source, "policy_id": policy,
              "policy_revision": policy_revision, "registry_hash": registry_hash,
              "request_hash": digest(canonical(request)), "request": request,
              "created_at": now(), "state": "dispatch_uncertain", "evaluation_id": None}
    # Crash after creation or during POST remains uncertain. Never replay this record.
    save(path, record, exclusive=True)
    try:
        result = api.request(f"/api/inference-policies/{policy}/revisions/{policy_revision}/qualifications", request, timeout=90)
        record["dispatch_result"] = result
        record["evaluation_id"] = result.get("id")
        evaluation_id = identifier(result["id"])
        if result.get("runtime_revision") != source or result.get("scope") != scope:
            raise OpsError("identity", "Dispatch returned an unexpected source or scope")
        record.update(state="dispatched", evaluation_id=evaluation_id, dispatch_result=result, updated_at=now())
    except BaseException as error:
        record.update(failure_category=getattr(error, "category", "uncertain"), updated_at=now())
        save(path, record)
        raise
    save(path, record)
    return record


def evaluation_status(api, evaluation_id, directory=None):
    identifier(evaluation_id)
    result = api.request("/api/inference-evaluations/" + evaluation_id)
    if result.get("id") != evaluation_id:
        raise OpsError("identity", "API returned a different evaluation")
    terminal = result.get("status") not in ("running", "queued", "pending")
    if result.get("scope", {}).get("kind") == "diagnostic" and result.get("qualification_id"):
        raise OpsError("evidence", "Diagnostic unexpectedly received qualification")
    if directory:
        # Terminal evidence is immutable; running snapshots may advance atomically.
        path = Path(directory) / (evaluation_id + (".result.json" if terminal else ".status.json"))
        if terminal and path.exists():
            prior = json.loads(path.read_text())["evaluation"]
            if prior != result:
                raise OpsError("evidence_changed", "Previously recorded terminal evaluation changed")
        else:
            save(path, {"observed_at": now(), "evaluation": result}, exclusive=terminal)
    return result


def evaluation_summary(result):
    report = result.get("report") or {}
    return {"evaluation_id": result["id"], "status": result["status"],
            "runtime_revision": result.get("runtime_revision"), "scope": result.get("scope"),
            "job_name": result.get("job_name"), "qualification_id": result.get("qualification_id"),
            "diagnostic": report.get("diagnostic"), "infrastructure_valid": report.get("infrastructure_valid"),
            "failure": result.get("failure")}


def watch_evaluation(api, evaluation_id, directory, deadline=600, interval=25):
    if not 1 <= deadline <= 86400 or not 1 <= interval <= 60:
        raise OpsError("input", "Deadline must be 1–86400 seconds and interval 1–60 seconds")
    end = time.monotonic() + deadline
    while True:
        result = evaluation_status(api, evaluation_id, directory)
        if result["status"] not in ("running", "queued", "pending"):
            return evaluation_summary(result)
        remaining = end - time.monotonic()
        if remaining <= 0:
            return {**evaluation_summary(result), "observation": "deadline_reached", "resume_by_id": True}
        time.sleep(min(interval, remaining))
