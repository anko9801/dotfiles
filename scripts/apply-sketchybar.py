#!/usr/bin/env python3
"""Apply a built bar-only bundle, retaining a rooted generation and rollback manifest."""
import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import time

NIX_STORE = "/nix/var/nix/profiles/default/bin/nix-store"
BAR = "/opt/homebrew/bin/sketchybar"
AEROSPACE = "/opt/homebrew/bin/aerospace"


def allowed(relative):
    path = Path(relative)
    return not path.is_absolute() and ".." not in path.parts and (
        relative.startswith(".config/sketchybar/")
        or relative == ".config/aerospace/aerospace.toml"
        or relative in {".local/bin/desktop-" + tool for tool in ("metrics", "network", "audio", "probe")}
    )


def run(*arguments):
    return subprocess.check_output(arguments, text=True, timeout=90).strip()


def link(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_name(target.name + ".sketchybar-new")
    temporary.unlink(missing_ok=True)
    temporary.symlink_to(source)
    os.replace(temporary, target)


def restore(manifest):
    records = json.loads(manifest.read_text())
    for record in records:
        if not allowed(record["path"]):
            raise ValueError("Unexpected rollback path")
        target = Path.home() / record["path"]
        if record["kind"] == "link":
            link(record["target"], target)
        elif record["kind"] == "file":
            temporary = target.with_name(target.name + ".sketchybar-new")
            shutil.copy2(manifest.parent / record["backup"], temporary)
            os.replace(temporary, target)
        else:
            target.unlink(missing_ok=True)


def healthy(expected):
    try:
        result = subprocess.run([BAR, "--query", "config.health"], capture_output=True, text=True, timeout=3)
        return result.returncode == 0 and json.loads(result.stdout).get("label", {}).get("value") == expected
    except (subprocess.SubprocessError, ValueError):
        return False


def reload():
    run(AEROSPACE, "reload-config")
    run(BAR, "--reload")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle", nargs="?", type=Path)
    parser.add_argument("--restore", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    if args.restore:
        restore(args.restore.resolve())
        reload()
        print("Previous bar generation restored.")
        return
    if not args.bundle:
        parser.error("Pass a built sketchybar-config bundle")
    bundle = args.bundle.resolve(strict=True)
    if not str(bundle).startswith("/nix/store/"):
        parser.error("The bundle must be a realized Nix store path")
    marker = bundle / ".config/sketchybar/generation-id"
    if not marker.is_file() or not re.fullmatch(r"[0-9a-f]{64}", marker.read_text().strip()):
        parser.error("The bundle does not contain a valid startup health marker")
    expected = marker.read_text().strip()
    sources = {}
    for prefix in (".config/sketchybar", ".local/bin"):
        for source in (bundle / prefix).rglob("*"):
            if source.is_file():
                relative = str(source.relative_to(bundle))
                if not allowed(relative):
                    parser.error("Unexpected bundle path")
                sources[relative] = source
    notifier = (bundle / "bin/aerospace-notify").resolve(strict=True)
    config = Path.home() / ".config/aerospace/aerospace.toml"
    text, count = re.subn(r"(?m)^exec-on-workspace-change\s*=.*$",
                          "exec-on-workspace-change = [" + json.dumps(str(notifier)) + "]", config.read_text())
    if count != 1 or not sources:
        parser.error("Unexpected workspace callback or empty bundle")
    if args.dry_run:
        print(f"Would apply {len(sources)} bar files and the workspace notifier; Dock and research processes are untouched.")
        return
    state = Path.home() / ".local/state/sketchybar/generations"
    state.mkdir(parents=True, exist_ok=True)
    generation = Path(tempfile.mkdtemp(prefix=datetime.now().strftime("%Y%m%dT%H%M%S-"), dir=state))
    run(NIX_STORE, "--realise", str(bundle), "--add-root", str(generation / "bundle"))
    rendered = generation / "aerospace.toml"
    rendered.write_text(text)
    aero = run(NIX_STORE, "--add", str(rendered))
    run(NIX_STORE, "--realise", aero, "--add-root", str(generation / "aerospace"))
    sources[".config/aerospace/aerospace.toml"] = Path(aero)
    records = []
    for index, relative in enumerate(sources):
        target = Path.home() / relative
        record = {"path": relative, "kind": "absent"}
        if target.is_symlink():
            record.update(kind="link", target=str(target.readlink()))
        elif target.is_file():
            backup = f"saved-{index}"
            shutil.copy2(target, generation / backup)
            record.update(kind="file", backup=backup)
        elif target.exists():
            raise ValueError("A target is not a regular file or symlink")
        records.append(record)
    manifest = generation / "rollback.json"
    manifest.write_text(json.dumps(records, indent=2) + "\n")
    try:
        for relative, source in sources.items():
            link(source, Path.home() / relative)
        reload()
        deadline = time.monotonic() + 45
        while not healthy(expected):
            if time.monotonic() >= deadline:
                raise RuntimeError("New bar configuration did not finish starting; rolling back")
            time.sleep(0.5)
    except Exception:
        restore(manifest)
        reload()
        raise
    print("Applied bar generation:", generation)
    print("Rollback:", manifest)


if __name__ == "__main__":
    main()
