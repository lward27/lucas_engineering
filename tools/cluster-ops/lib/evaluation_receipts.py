"""Retain bounded execution observations without changing native evaluation results."""
import json
from pathlib import Path

from .common import OpsError, identifier, now, save

EVALUATION_LABEL = "pharness.lucas.engineering/inference-evaluation-id"


def container_status(value):
    result = {k: value.get(k) for k in ("name", "image", "imageID", "ready", "restartCount")}
    result["state"] = {}
    for kind, fields in (("running", ("startedAt",)), ("waiting", ("reason",)),
                         ("terminated", ("exitCode", "signal", "reason", "startedAt", "finishedAt"))):
        state = value.get("state", {}).get(kind)
        if state is not None:
            result["state"][kind] = {k: state[k] for k in fields if k in state}
    return result


def execution_receipt(profile, evaluation, directory):
    evaluation_id = identifier(evaluation["id"])
    namespace = profile.data["pharness"]["namespace"]
    directory = Path(directory)
    final = directory / (evaluation_id + ".execution.json")
    snapshot = directory / (evaluation_id + ".execution.status.json")
    observation = directory / (evaluation_id + ".execution-observation.json")
    identity = {"evaluation_id": evaluation_id, "context": profile.context,
                "api_server": profile.data["api_server"], "namespace": namespace,
                "runtime_revision": evaluation.get("runtime_revision"), "job_name": evaluation.get("job_name")}
    if final.exists():
        prior = json.loads(final.read_text())
        if prior.get("status") != "captured" or any(prior.get(k) != v for k, v in identity.items()):
            raise OpsError("identity", "Retained execution receipt belongs to a different evaluation or cluster")
        return {"status": "captured", "path": str(final), "retained": True}

    def gap(status, category=None):
        value = {**identity, "observed_at": now(), "status": status,
                 "meaning": "Missing observation is not evaluation failure or permission to redispatch.",
                 "prior_snapshot": str(snapshot) if snapshot.exists() else None}
        if category:
            value["failure_category"] = category
        save(observation, value)
        return {"status": status, "path": str(observation), "resume_by_id": True}

    name = evaluation.get("job_name")
    if not name:
        return gap("job_not_recorded")
    identifier(name)
    if not name.startswith("pharness-inference-eval-"):
        raise OpsError("identity", "Native evaluation returned an unexpected Job name")
    try:
        job = profile.get("job/" + name, namespace)
        metadata = job["metadata"]
        if (metadata["name"] != name or metadata.get("namespace") != namespace
                or metadata.get("labels", {}).get(EVALUATION_LABEL) != evaluation_id.replace("_", "-")):
            raise OpsError("identity", "Job does not identify the requested evaluation")
        uid = metadata["uid"]
        if snapshot.exists():
            prior = json.loads(snapshot.read_text())
            if any(prior.get(k) != v for k, v in identity.items()) or prior["job"]["uid"] != uid:
                raise OpsError("identity", "Observed evaluation Job identity changed; previous evidence is retained")
        pods = json.loads(profile.kubectl(["get", "pods", "-l", "job-name=" + name, "-o", "json"], namespace=namespace))["items"]
        for pod in pods:
            if pod["metadata"].get("namespace") != namespace or not any(
                owner.get("uid") == uid and owner.get("kind") == "Job" and owner.get("name") == name
                and owner.get("controller") is True for owner in pod["metadata"].get("ownerReferences", [])
            ):
                raise OpsError("identity", "Selected Pod is not owned by the observed evaluation Job")
    except OpsError as error:
        if error.category == "identity":
            raise
        return gap("missing" if error.category == "not_found" else "unavailable", error.category)

    status = job.get("status", {})
    conditions = [{k: c[k] for k in ("type", "status", "reason", "lastTransitionTime") if k in c}
                  for c in status.get("conditions", [])]
    terminal = any(c.get("status") == "True" and c.get("type") in ("Complete", "Failed") for c in conditions)
    captured = terminal and bool(pods) and all(p.get("status", {}).get("phase") in ("Succeeded", "Failed") for p in pods)
    value = {"schema_version": 1, **identity, "observed_at": now(), "status": "captured" if captured else "pending",
             "meaning": "Execution observation only; process completion does not establish a passing evaluation or qualification.",
             "job": {"uid": uid, "status": {k: status[k] for k in ("startTime", "completionTime", "active", "succeeded", "failed") if k in status},
                     "conditions": conditions, "configured_images": [{"name": c["name"], "image": c["image"]} for c in job["spec"]["template"]["spec"]["containers"]]},
             "pods": [{"name": p["metadata"]["name"], "uid": p["metadata"]["uid"], "node": p["spec"].get("nodeName"),
                       "phase": p.get("status", {}).get("phase"),
                       "init_containers": [container_status(c) for c in p.get("status", {}).get("initContainerStatuses", [])],
                       "containers": [container_status(c) for c in p.get("status", {}).get("containerStatuses", [])]} for p in pods]}
    save(final if captured else snapshot, value, exclusive=captured)
    if terminal and not pods:
        return gap("pod_missing")
    return {"status": value["status"], "path": str(final if captured else snapshot), "retained": False}
