import copy
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from lib.common import OpsError, Profile, canonical, digest, run
from lib.connections import Tunnel, Pharness
from lib.operations import evaluation_status, start_evaluation
from lib.releases import COMPONENTS, validate_manifest, verify_release
from lib.builder import inspect as inspect_builder, BuilderConnection

SHARED = ROOT / "skills/_shared/scripts"
SOURCE = "1" * 40
REGISTRY = "sha256:" + "2" * 64


class GuardTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.log = self.root / "calls.jsonl"
        self.env = {**os.environ, "PATH": str(self.root) + os.pathsep + os.environ["PATH"],
                    "FAKE_LOG": str(self.log), "PYTHONDONTWRITEBYTECODE": "1"}
        kubeconfig = self.root / "kubeconfig"
        kubeconfig.write_text("test fixture")
        self.profile = self.root / "profile.yaml"
        self.profile.write_text(f'''approved_contexts:
  - name: expected
    aliases: ["fixture"]
    kubeconfig: "{kubeconfig}"
    api_server: "https://expected:6443"
    environment: test
    writes_allowed: true
unknown_context_policy:
  writes_allowed: false
''')
        tool = self.root / "kubectl"
        tool.write_text('''#!/usr/bin/env python3
import json,os,sys
args=sys.argv[1:]
with open(os.environ['FAKE_LOG'],'a') as log:log.write(json.dumps(args)+'\\n')
if 'get-contexts' in args:print('expected')
elif 'view' in args:print(os.environ.get('FAKE_SERVER','https://expected:6443'),end='')
elif 'get' in args:
 if os.environ.get('FAKE_OWNER_FAIL'):
  print('Forbidden',file=sys.stderr);sys.exit(6)
 print('fixture-owner',end='')
elif '--dry-run=client' in args:sys.exit(int(os.environ.get('FAKE_CLIENT_EXIT','0')))
elif '--dry-run=server' in args:sys.exit(int(os.environ.get('FAKE_SERVER_EXIT','0')))
else:sys.exit(99)
''')
        tool.chmod(0o755)

    def invoke(self, script, *args):
        return subprocess.run(["bash", str(SHARED / script), *args], env=self.env, capture_output=True, text=True, timeout=10)

    def test_scoped_read_classifies(self):
        for args in ["kubectl --context fixture --request-timeout=20s -n ns get pods",
                     "kubectl --kubeconfig /tmp/example --context=fixture get pods -n ns"]:
            result = self.invoke("operation-classifier.sh", "--command", args)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("class=observation", result.stdout)

    def test_compound_or_substitution_never_read(self):
        for command in ["kubectl get pods; kubectl delete ns production", "kubectl get pods && kubectl apply -f x",
                        'kubectl get pods $(touch /tmp/never)', "kubectl get pods | sh",
                        "kubectl get pods\nkubectl delete ns production", "kubectl get pods >> x"]:
            result = self.invoke("operation-classifier.sh", "--command", command)
            self.assertEqual(result.returncode, 3, command)
        self.assertFalse(self.log.exists())

    def test_classifications_preserve_effects(self):
        cases = [(["kubectl", "apply", "--dry-run=server", "-f", "x"], "observation"),
                 (["kubectl", "apply", "--dry-run=false", "-f", "x"], "non-destructive-mutation"),
                 (["kubectl", "--context", "fixture", "delete", "job/x"], "destructive-high-risk"),
                 (["argocd", "app", "sync", "x", "--prune=false"], "non-destructive-mutation"),
                 (["argocd", "app", "sync", "x", "--prune"], "destructive-high-risk"),
                 (["argocd", "app", "sync", "x", "--prune", "false"], "destructive-high-risk"),
                 (["kubectl", "scale", "deployment/x", "--replicas", "0"], "destructive-high-risk")]
        for argv, expected in cases:
            result = self.invoke("operation-classifier.sh", "--argv-json", json.dumps(argv))
            self.assertEqual(result.returncode, 0)
            self.assertIn("class=" + expected + "\n", result.stdout)

    def preflight(self):
        manifest = self.root / "manifest.yaml"
        manifest.write_text("apiVersion: v1\nkind: ConfigMap\nmetadata:\n  name: fixture\n")
        return self.invoke("mutation-preflight.sh", "--context", "fixture", "--namespace", "test",
                           "--resource", "configmap/fixture", "--profile", str(self.profile),
                           "--argv-json", json.dumps(["kubectl", "--context", "fixture", "apply", "-f", str(manifest)]),
                           "--manifest", str(manifest))

    def test_failed_client_stops_before_server(self):
        self.env["FAKE_CLIENT_EXIT"] = "7"
        result = self.preflight()
        self.assertEqual(result.returncode, 7, result.stdout + result.stderr)
        self.assertNotIn("--dry-run=server", self.log.read_text())

    def test_failed_server_is_not_success(self):
        self.env["FAKE_SERVER_EXIT"] = "9"
        self.assertEqual(self.preflight().returncode, 9)

    def test_unknown_ownership_stops(self):
        self.env["FAKE_OWNER_FAIL"] = "1"
        self.assertNotEqual(self.preflight().returncode, 0)
        self.assertNotIn("--dry-run", self.log.read_text())

    def test_preflight_succeeds_without_actual_apply(self):
        result = self.preflight()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for args in map(json.loads, self.log.read_text().splitlines()):
            self.assertIn("--request-timeout=20s", args)
            if "apply" in args:
                self.assertTrue(any(a.startswith("--dry-run=") for a in args))

    def test_wrong_server_is_rejected(self):
        self.env["FAKE_SERVER"] = "https://other-cluster:6443"
        self.assertNotEqual(self.preflight().returncode, 0)
        self.assertNotIn('"get"', self.log.read_text())

    def test_ambiguous_alias_rejected_before_kubectl(self):
        text = self.profile.read_text()
        block = text.split("unknown_context_policy:")[0].replace("approved_contexts:\n", "")
        self.profile.write_text(text.replace("unknown_context_policy:", block + "unknown_context_policy:"))
        self.assertNotEqual(self.preflight().returncode, 0)
        self.assertFalse(self.log.exists())


class ConnectionTests(unittest.TestCase):
    def tunnel_case(self, method):
        tunnel = Tunnel(Mock(), "ns", "service/example", 80)
        def connect():
            tunnel.process = Mock()
            tunnel.process.poll.return_value = None
            tunnel.local_port = 1
        with patch.object(tunnel, "connect", side_effect=connect) as connections, \
             patch("lib.connections.http.client.HTTPConnection") as client:
            client.return_value.request.side_effect = OSError("disconnected")
            with self.assertRaises(OpsError):
                tunnel.request(method, "/api/test")
            return connections.call_count, client.return_value.request.call_count

    def test_read_reconnects_but_write_never_repeats(self):
        self.assertEqual(self.tunnel_case("GET"), (2, 2))
        self.assertEqual(self.tunnel_case("POST"), (1, 1))

    def test_private_command_does_not_capture_to_disk_or_echo_error(self):
        with patch("lib.common.tempfile.TemporaryFile", side_effect=AssertionError("private data touched disk")), \
             patch("lib.common.subprocess.run", return_value=Mock(returncode=0, stdout=b"fixture-secret")):
            self.assertEqual(run(["kubectl", "get", "secret/named"], private=True), b"fixture-secret")
        with patch("lib.common.subprocess.run", return_value=Mock(returncode=1, stdout=b"", stderr=b"fixture-secret")):
            with self.assertRaises(OpsError) as error:
                run(["kubectl"], private=True)
            self.assertNotIn("fixture-secret", str(error.exception))

    def test_remote_response_cannot_echo_token(self):
        api = Pharness(Mock(data={"pharness": {"namespace": "x", "resource": "service/x", "port": 1}}))
        api.token = "fixture-secret"
        with patch.object(api.tunnel, "request", return_value=b'{"echo":"fixture-secret"}'):
            self.assertEqual(api.request("/api/test"), {"echo": "[redacted]"})

    def test_builder_refuses_unexpected_endpoint_before_tls(self):
        profile = Mock(data={"builder": {"name": "lucas-desktop", "docker_context": "rancher-desktop",
                                       "client_endpoint": "tcp://127.0.0.1:12342"}})
        with patch("lib.builder.run", return_value=b"Driver: remote\nEndpoint: tcp://other-host:12340\nPlatforms: linux/amd64\n"), \
             patch("lib.builder.socket.create_connection") as connection:
            with self.assertRaises(OpsError): inspect_builder(profile)
            connection.assert_not_called()

    def test_builder_does_not_replace_an_occupied_unverified_port(self):
        profile = Mock(data={"builder": {"client_endpoint": "tcp://127.0.0.1:12342"}})
        with patch("lib.builder.socket.create_connection") as connection, \
             patch("lib.builder.inspect", side_effect=OpsError("identity", "wrong peer")), \
             patch("lib.builder.subprocess.Popen") as launch:
            with self.assertRaises(OpsError):
                with BuilderConnection(profile): pass
            launch.assert_not_called()

    def test_cli_existing_receipt_stops_before_operations(self):
        with tempfile.TemporaryDirectory() as temp:
            output = Path(temp) / "receipt.json"
            output.write_text('{"retained":true}')
            result = subprocess.run([sys.executable, str(ROOT / 'lucas-ops'), '--profile', '/missing-profile',
                                     'builder', 'preflight', '--repo', '/missing-repo', '--source-revision', SOURCE,
                                     '--output', str(output)], capture_output=True, text=True, timeout=5)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(json.loads(result.stdout)['category'], 'existing_record')
            self.assertEqual(output.read_text(), '{"retained":true}')


class EvaluationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.profile = Mock(context="lucas_engineering")
        self.request = {"actor": "test", "reason": "explicit fixture", "config_hash": REGISTRY,
                        "attempts": 1, "scope": {"kind": "diagnostic", "case_ids": ["python-contract"]}}
        self.ready = {"api_revision": SOURCE, "ui_revision": SOURCE, "platform_versions_match": True,
                      "operational_mode": "normal", "inference": {"api_registry_hash": REGISTRY, "registry_aligned": True}}

    def start(self, api):
        return start_evaluation(self.profile, api, self.request, "fixture", "v1", SOURCE, REGISTRY, self.directory, "operation")

    def test_interrupted_dispatch_retained_and_cannot_repeat(self):
        api = Mock()
        posts = []
        def request(path, body=None, timeout=None):
            if body is None:
                return self.ready
            self.assertTrue((self.directory / "operation.json").exists())
            posts.append(body)
            raise OpsError("transport", "Uncertain write")
        api.request.side_effect = request
        with self.assertRaises(OpsError): self.start(api)
        with self.assertRaises(OpsError): self.start(api)
        self.assertEqual(len(posts), 1)
        self.assertEqual(json.loads((self.directory / "operation.json").read_text())["state"], "dispatch_uncertain")

    def test_stale_source_sends_no_post(self):
        api = Mock()
        api.request.return_value = {**self.ready, "api_revision": "3" * 40}
        with self.assertRaises(OpsError): self.start(api)
        self.assertEqual(api.request.call_count, 1)
        self.assertFalse((self.directory / "operation.json").exists())

    def test_terminal_result_is_immutable(self):
        api = Mock()
        value = {"id": "infeval_example", "status": "completed", "qualification_id": None,
                 "scope": self.request["scope"], "report": {"diagnostic": {"passed": False}}}
        api.request.return_value = value
        evaluation_status(api, "infeval_example", self.directory)
        evaluation_status(api, "infeval_example", self.directory)
        api.request.return_value = {**value, "status": "failed"}
        with self.assertRaises(OpsError): evaluation_status(api, "infeval_example", self.directory)

    def test_diagnostic_never_claims_qualification(self):
        api = Mock()
        api.request.return_value = {"id": "infeval_example", "status": "completed", "scope": self.request["scope"], "qualification_id": "invalid"}
        with self.assertRaises(OpsError): evaluation_status(api, "infeval_example", self.directory)


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.bundle = Path(self.temp.name) / "bundle.tar.gz"
        self.bundle.write_bytes(b"fixture-bundle")
        self.config = {"os": "linux", "architecture": "amd64", "config": {"Labels": {
            "org.opencontainers.image.revision": SOURCE, "org.opencontainers.image.source": "https://github.com/lward27/pharness"}}}

    def fixture(self):
        config = canonical(self.config)
        image = canonical({"config": {"digest": digest(config)}})
        release = {"schema_version": 1, "source_revision": SOURCE,
                   "images": {c: {"repository": "pharness-"+c, "digest": digest(image)} for c in COMPONENTS},
                   "native_bundle": {"path": str(self.bundle), "digest": digest(self.bundle.read_bytes())}}
        profile = Mock(data={"sources": {"pharness": {"repository": "https://github.com/lward27/pharness.git"}}})
        return release, profile, config, image

    def verify(self):
        release, profile, config, image = self.fixture()
        with patch("lib.releases.registry_read", side_effect=lambda p,r,s,a=None: (config if s.startswith("blobs/") else image, {})):
            return verify_release(profile, release)

    def test_all_components_verified_without_claiming_provenance(self):
        result = self.verify()
        self.assertEqual(set(result["images"]), set(COMPONENTS))
        self.assertFalse(result["provenance_attestation_verified"])

    def test_wrong_platform_or_revision_fails(self):
        self.config["architecture"] = "arm64"
        with self.assertRaises(OpsError): self.verify()
        self.config["architecture"] = "amd64"
        self.config["config"]["Labels"]["org.opencontainers.image.revision"] = "4" * 40
        with self.assertRaises(OpsError): self.verify()

    def test_corrupt_registry_data_fails(self):
        release, profile, config, image = self.fixture()
        with patch("lib.releases.registry_read", return_value=(image + b" ", {})):
            with self.assertRaises(OpsError): verify_release(profile, release)

    def test_missing_component_and_mutable_tag_fail(self):
        release, *_ = self.fixture()
        del release["images"]["ui"]
        with self.assertRaises(OpsError): validate_manifest(release)
        release, *_ = self.fixture()
        release["images"]["ui"]["digest"] = "latest"
        with self.assertRaises(OpsError): validate_manifest(release)


class InstallTests(unittest.TestCase):
    def test_install_preserves_unrelated_files_and_restores(self):
        spec = importlib.util.spec_from_file_location("installer", ROOT / "install.py")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            skills = root / "skills"
            skills.mkdir()
            unrelated = skills / "user-skill.txt"
            unrelated.write_text("preserve")
            result = module.install(root / "runtime", skills, root / "bin")
            self.assertEqual(unrelated.read_text(), "preserve")
            self.assertTrue((root / "bin/lucas-ops").is_symlink())
            module.restore(Path(result["manifest"]))
            self.assertEqual(unrelated.read_text(), "preserve")
            self.assertFalse((root / "bin/lucas-ops").exists())

    def test_installer_refuses_unreviewed_skill_edit(self):
        spec = importlib.util.spec_from_file_location("installer", ROOT / "install.py")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / "skills/_shared/scripts/context-guard.sh"
            target.parent.mkdir(parents=True)
            target.write_text("user modification")
            with self.assertRaises(OpsError): module.install(root / "runtime", root / "skills", root / "bin")
            self.assertEqual(target.read_text(), "user modification")
            self.assertFalse((root / "runtime").exists())


if __name__ == "__main__":
    unittest.main()
