#!/usr/bin/env python3
"""Install a content-addressed operator bundle and update only known skill files."""
import argparse
import hashlib
import json
import os
import shutil
from pathlib import Path

from lib.common import OpsError, canonical, digest, now, save

ROOT = Path(__file__).resolve().parent


def files(root):
    return {str(p.relative_to(root)): digest(p.read_bytes()) for p in sorted(root.rglob("*"))
            if p.is_file() and "__pycache__" not in p.parts and not p.name.endswith(".pyc")}


def symlink(target, path):
    temporary = path.with_name(path.name + ".pending")
    if temporary.exists() or temporary.is_symlink():
        raise OpsError("install_conflict", "A previous pending installation must be reconciled")
    temporary.symlink_to(target)
    os.replace(temporary, path)


def install(prefix, skills, bin_dir):
    source_files = files(ROOT)
    version = digest(canonical(source_files)).split(":")[1]
    runtime = prefix / "versions" / version
    prior_file = prefix / "installation.json"
    prior = json.loads(prior_file.read_text()) if prior_file.exists() else {}
    expected_base = json.loads((ROOT / "skills-base-sha256.json").read_text())
    skill_files = files(ROOT / "skills")
    before = {}
    for relative, new_hash in skill_files.items():
        target = skills / relative
        old_hash = digest(target.read_bytes()) if target.is_file() else None
        allowed = {None, expected_base.get(relative), prior.get("skill_files", {}).get(relative), new_hash}
        if target.is_symlink() or (target.exists() and not target.is_file()) or old_hash not in allowed:
            raise OpsError("install_conflict", "Installed skill has an unreviewed local change: " + relative)
        before[relative] = old_hash
    launcher = bin_dir / "lucas-ops"
    current = prefix / "current"
    if launcher.exists() or launcher.is_symlink():
        if not launcher.is_symlink() or launcher.readlink() != current / "lucas-ops":
            raise OpsError("install_conflict", "Existing lucas-ops command is not managed by this installer")
    if current.exists() and not current.is_symlink():
        raise OpsError("install_conflict", "Runtime current path is not a managed symlink")
    old_current = str(current.readlink()) if current.is_symlink() else None
    if runtime.exists():
        if files(runtime) != source_files:
            raise OpsError("install_conflict", "Content-addressed runtime was modified")
    else:
        runtime.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(ROOT, runtime, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
    backup = prefix / "backups" / now().replace(":", "-")
    backup.mkdir(parents=True, mode=0o700)
    for relative, old_hash in before.items():
        if old_hash is not None:
            target = backup / "skills" / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(skills / relative, target)
    manifest = {"schema_version": 1, "installed_at": now(), "runtime": str(runtime),
                "version": version, "source": str(ROOT), "source_files": source_files,
                "skills_dir": str(skills), "bin_dir": str(bin_dir), "prefix": str(prefix),
                "skill_files": skill_files, "prior_skill_files": before, "prior_runtime": old_current,
                "backup": str(backup), "state": "prepared"}
    save(backup / "installation.json", manifest, exclusive=True)
    for relative in skill_files:
        target = skills / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(runtime / "skills" / relative, target)
    bin_dir.mkdir(parents=True, exist_ok=True)
    symlink(runtime, current)
    if not launcher.is_symlink():
        launcher.symlink_to(current / "lucas-ops")
    manifest["state"] = "installed"
    save(backup / "installation.json", manifest)
    save(prior_file, manifest)
    return {"status": "installed", "version": version, "command": str(launcher),
            "manifest": str(backup / "installation.json"), "skill_files": len(skill_files)}


def restore(path):
    manifest = json.loads(path.read_text())
    skills, backup = Path(manifest["skills_dir"]), Path(manifest["backup"])
    for relative, installed_hash in manifest["skill_files"].items():
        target = skills / relative
        if not target.is_file() or target.is_symlink() or digest(target.read_bytes()) != installed_hash:
            raise OpsError("install_conflict", "Installed file changed since installation: " + relative)
        prior = manifest["prior_skill_files"][relative]
        if prior is not None and digest((backup / "skills" / relative).read_bytes()) != prior:
            raise OpsError("install_conflict", "Backup hash mismatch")
    current = Path(manifest["prefix"]) / "current"
    if not current.is_symlink() or str(current.readlink()) != manifest["runtime"]:
        raise OpsError("install_conflict", "A newer runtime installation must be reconciled first")
    for relative, prior in manifest["prior_skill_files"].items():
        target = skills / relative
        if prior is None:
            target.unlink()
        else:
            shutil.copy2(backup / "skills" / relative, target)
    if manifest["prior_runtime"]:
        symlink(Path(manifest["prior_runtime"]), current)
    else:
        current.unlink()
        launcher = Path(manifest["bin_dir"]) / "lucas-ops"
        if launcher.is_symlink() and launcher.readlink() == current / "lucas-ops":
            launcher.unlink()
    save(Path(manifest["prefix"]) / "installation.json", {"state": "restored", "skill_files": manifest["prior_skill_files"]})
    return {"status": "restored", "manifest": str(path)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prefix", type=Path, default=Path.home() / ".local/share/lucas-ops")
    parser.add_argument("--skills-dir", type=Path, default=Path.home() / ".agents/skills")
    parser.add_argument("--bin-dir", type=Path, default=Path.home() / ".local/bin")
    parser.add_argument("--restore", type=Path)
    args = parser.parse_args()
    print(json.dumps(restore(args.restore) if args.restore else install(args.prefix.resolve(), args.skills_dir.resolve(), args.bin_dir.resolve()), indent=2))


if __name__ == "__main__":
    try:
        main()
    except OpsError as error:
        print(json.dumps({"status": "failed", "category": error.category, "detail": str(error)}))
        raise SystemExit(1)
