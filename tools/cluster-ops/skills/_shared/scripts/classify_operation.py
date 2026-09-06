#!/usr/bin/env python3
"""Classify one argv sequence. This is advisory, never execution authorization."""
import argparse
import json
import shlex
from pathlib import Path


def classify(argv):
    uncertain = ("uncertain", "unsupported-or-compound-command")
    if not argv or any(token and all(c in ";&|<>()" for c in token) for token in argv):
        return uncertain
    if any("$(" in token or "`" in token or "\n" in token for token in argv):
        return uncertain
    program = Path(argv[0]).name
    args = argv[1:]
    global_values = {"--context", "--kubeconfig", "--namespace", "-n", "--request-timeout",
                     "--as", "--as-group", "--cluster", "--user", "--server"}
    while args and args[0].startswith("-"):
        flag = args[0].split("=", 1)[0]
        if flag not in global_values:
            return uncertain
        if "=" in args[0]:
            args = args[1:]
        elif len(args) > 1:
            args = args[2:]
        else:
            return uncertain
    if not args:
        return uncertain
    verb = args[0]

    def enabled(flag):
        for i, value in enumerate(args):
            if value == flag:
                return True
            if value.startswith(flag + "="):
                return value.split("=", 1)[1] != "false"
        return False

    destructive = verb in {"delete", "uninstall", "drain", "cordon"} or enabled("--force") or enabled("--prune")
    destructive |= args[:2] in [["rollout", "undo"], ["pipelinerun", "cancel"], ["taskrun", "cancel"]]
    destructive |= any(value == "--replicas=0" or (value == "--replicas" and args[i+1:i+2] == ["0"])
                       for i, value in enumerate(args))
    if destructive:
        return "destructive-high-risk", "service-data-or-history-impact"
    if program == "kubectl":
        if verb in {"get", "describe", "logs", "top", "events", "diff", "api-resources", "api-versions", "version"}:
            return "observation", "kubernetes-read"
        if args[:2] in [["rollout", "status"], ["rollout", "history"], ["auth", "can-i"],
                        ["config", "view"], ["config", "get-contexts"], ["config", "current-context"]]:
            return "observation", "kubernetes-read"
        if verb in {"apply", "create", "patch", "replace"}:
            dry = any(value in {"--dry-run=client", "--dry-run=server"} or
                      (value == "--dry-run" and args[i+1:i+2] in [["client"], ["server"]])
                      for i, value in enumerate(args))
            return ("observation", "kubernetes-dry-run") if dry else ("non-destructive-mutation", "kubernetes-write")
        if verb in {"label", "annotate", "scale"} or args[:2] in [["rollout", "restart"], ["set", "image"]]:
            return "non-destructive-mutation", "kubernetes-write"
    if program == "argocd" and args[:2] in [["app", "get"], ["app", "diff"], ["app", "list"]]:
        return "observation", "gitops-read"
    if program == "argocd" and args[:2] == ["app", "sync"]:
        return "non-destructive-mutation", "gitops-sync"
    if program == "helm":
        if verb in {"get", "list", "status", "template", "lint", "show"}:
            return "observation", "helm-read-or-render"
        if verb in {"upgrade", "install"}:
            return ("observation", "helm-dry-run") if enabled("--dry-run") else ("non-destructive-mutation", "helm-write")
        if verb == "rollback":
            return "destructive-high-risk", "rollback"
    if program == "tkn" and len(args) > 1 and args[1] in {"describe", "list", "logs"}:
        return "observation", "tekton-read"
    if (program == "hubble" and verb == "observe") or (program == "cilium" and verb == "status"):
        return "observation", "network-observation"
    return uncertain


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--context")
    inputs = parser.add_mutually_exclusive_group(required=True)
    inputs.add_argument("--command", help="Compatibility input; one command only, never evaluated")
    inputs.add_argument("--argv-json", help="Preferred JSON array of argument strings")
    args = parser.parse_args()
    try:
        if args.argv_json:
            argv = json.loads(args.argv_json)
            if not isinstance(argv, list) or not all(isinstance(a, str) for a in argv):
                raise ValueError("Expected array")
        else:
            if "\n" in args.command or "\r" in args.command:
                raise ValueError("Compound lines are not supported")
            lexer = shlex.shlex(args.command, posix=True, punctuation_chars=True)
            lexer.whitespace_split = True
            lexer.commenters = ""
            argv = list(lexer)
        category, reason = classify(argv)
    except (ValueError, TypeError):
        category, reason = "uncertain", "invalid-argument-sequence"
    if args.context:
        print("requested_context=" + args.context)
    print("class=" + category)
    print("reason=" + reason)
    return 3 if category == "uncertain" else 0


if __name__ == "__main__":
    raise SystemExit(main())
