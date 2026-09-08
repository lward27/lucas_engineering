import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from lib.common import OpsError, canonical
from lib.evaluation_receipts import EVALUATION_LABEL, execution_receipt
from lib.operations import watch_evaluation


class ExecutionReceiptTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.evaluation = {"id": "infeval_fixture", "status": "completed", "runtime_revision": "1" * 40,
                           "job_name": "pharness-inference-eval-fixture", "qualification_id": None,
                           "scope": {"kind": "diagnostic", "case_ids": ["python-contract"]},
                           "report": {"diagnostic": {"passed": False}}}
        self.profile = Mock(context="lucas_engineering", data={"api_server": "https://expected:6443", "pharness": {"namespace": "pharness"}})
        self.job = {"metadata": {"name": self.evaluation["job_name"], "namespace": "pharness", "uid": "job-original",
                                 "labels": {EVALUATION_LABEL: "infeval-fixture"}, "annotations": {"private": "FIXTURE_SECRET"}},
                    "spec": {"template": {"spec": {"containers": [{"name": "evaluate", "image": "registry/eval@sha256:fixture",
                                                                      "env": [{"name": "GRANT", "value": "FIXTURE_SECRET"}]}]}}},
                    "status": {"succeeded": 1, "conditions": [{"type": "Complete", "status": "True", "message": "FIXTURE_SECRET"}]}}
        self.pod = {"metadata": {"name": "pod-original", "namespace": "pharness", "uid": "pod-uid",
                                 "ownerReferences": [{"name": self.evaluation["job_name"], "uid": "job-original", "kind": "Job", "controller": True}]},
                    "spec": {"nodeName": "worker", "private": "FIXTURE_SECRET"},
                    "status": {"phase": "Succeeded", "containerStatuses": [{"name": "evaluate", "imageID": "registry/eval@sha256:fixture",
                                  "restartCount": 0, "state": {"terminated": {"exitCode": 0, "message": "FIXTURE_SECRET"}}}]}}
        self.profile.get.return_value = self.job
        self.profile.kubectl.return_value = canonical({"items": [self.pod]})
        self.api = Mock(profile=self.profile)
        self.api.request.return_value = self.evaluation

    def pending(self):
        job, pod = copy.deepcopy(self.job), copy.deepcopy(self.pod)
        job["status"] = {"active": 1}
        pod["status"]["phase"] = "Running"
        pod["status"]["containerStatuses"][0]["state"] = {"running": {"startedAt": "observed-start"}}
        return job, pod

    def test_waits_for_process_exit_after_native_callback_without_changing_verdict(self):
        job, pod = self.pending()
        self.profile.get.side_effect = [job, self.job]
        self.profile.kubectl.side_effect = [canonical({"items": [pod]}), canonical({"items": [self.pod]})]
        with patch("lib.operations.time.sleep") as pause:
            result = watch_evaluation(self.api, "infeval_fixture", self.directory)
        pause.assert_called_once()
        self.assertEqual(result["status"], "completed")
        self.assertFalse(result["diagnostic"]["passed"])
        self.assertEqual(result["execution_receipt"]["status"], "captured")
        receipt = json.loads(Path(result["execution_receipt"]["path"]).read_text())
        self.assertEqual(receipt["pods"][0]["containers"][0]["state"]["terminated"]["exitCode"], 0)
        for path in self.directory.iterdir():
            self.assertNotIn("FIXTURE_SECRET", path.read_text())
        native = json.loads((self.directory / "infeval_fixture.result.json").read_text())
        self.assertEqual(native["evaluation"], self.evaluation)
        self.assertTrue(all(call.args == ("/api/inference-evaluations/infeval_fixture",) for call in self.api.request.call_args_list))

    def test_terminal_receipt_survives_expiry_and_rejects_different_identity(self):
        result = execution_receipt(self.profile, self.evaluation, self.directory)
        retained = Path(result["path"]).read_bytes()
        self.profile.get.reset_mock()
        self.profile.get.side_effect = OpsError("not_found", "expired")
        result = execution_receipt(self.profile, self.evaluation, self.directory)
        self.assertTrue(result["retained"])
        self.profile.get.assert_not_called()
        self.assertEqual(Path(result["path"]).read_bytes(), retained)
        with self.assertRaises(OpsError):
            execution_receipt(self.profile, {**self.evaluation, "runtime_revision": "2" * 40}, self.directory)

    def test_expired_job_keeps_native_failure_and_never_redispatches(self):
        self.profile.get.side_effect = OpsError("not_found", "expired")
        result = watch_evaluation(self.api, "infeval_fixture", self.directory)
        self.assertFalse(result["diagnostic"]["passed"])
        self.assertEqual(result["execution_receipt"]["status"], "missing")
        self.assertFalse((self.directory / "infeval_fixture.execution.json").exists())
        self.api.request.assert_called_once_with("/api/inference-evaluations/infeval_fixture")

    def test_observation_failure_does_not_become_an_evaluation_failure(self):
        self.profile.get.side_effect = OpsError("permission", "read denied")
        result = watch_evaluation(self.api, "infeval_fixture", self.directory)
        self.assertEqual(result["status"], "completed")
        self.assertEqual(result["execution_receipt"]["status"], "unavailable")

    def test_deadline_preserves_pending_receipt_without_stopping_remote_work(self):
        job, pod = self.pending()
        self.profile.get.return_value = job
        self.profile.kubectl.return_value = canonical({"items": [pod]})
        with patch("lib.operations.time.monotonic", side_effect=[0, 2]):
            result = watch_evaluation(self.api, "infeval_fixture", self.directory, deadline=1)
        self.assertEqual(result["observation"], "deadline_reached")
        self.assertEqual(result["execution_receipt"]["status"], "pending")
        self.assertTrue((self.directory / "infeval_fixture.execution.status.json").exists())
        self.assertFalse((self.directory / "infeval_fixture.execution.json").exists())

    def test_wrong_job_label_or_pod_owner_cannot_supply_evidence(self):
        for kind in ("label", "owner"):
            with self.subTest(kind=kind):
                job, pod = copy.deepcopy(self.job), copy.deepcopy(self.pod)
                if kind == "label":
                    job["metadata"]["labels"][EVALUATION_LABEL] = "different-evaluation"
                else:
                    pod["metadata"]["ownerReferences"][0]["uid"] = "different-job"
                self.profile.get.return_value = job
                self.profile.kubectl.return_value = canonical({"items": [pod]})
                with self.assertRaises(OpsError):
                    execution_receipt(self.profile, self.evaluation, self.directory)
                self.assertFalse((self.directory / "infeval_fixture.execution.json").exists())

    def test_changed_job_uid_cannot_replace_previous_observation(self):
        job, pod = self.pending()
        self.profile.get.return_value = job
        self.profile.kubectl.return_value = canonical({"items": [pod]})
        initial = execution_receipt(self.profile, self.evaluation, self.directory)
        before = Path(initial["path"]).read_bytes()
        changed = copy.deepcopy(self.job)
        changed["metadata"]["uid"] = "recreated-job"
        self.profile.get.return_value = changed
        with self.assertRaises(OpsError):
            execution_receipt(self.profile, self.evaluation, self.directory)
        self.assertEqual(Path(initial["path"]).read_bytes(), before)
