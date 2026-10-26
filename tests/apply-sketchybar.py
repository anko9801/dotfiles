import importlib.util
import json
from pathlib import Path
import tempfile
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location("apply_bar", "scripts/apply-sketchybar.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
assert module.allowed(".config/sketchybar/items/spaces.lua")
for name in ["/etc/hosts", ".config/sketchybar/../../hosts", ".local/bin/python", ".config/aerospace/other"]:
    assert not module.allowed(name)
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    home = root / "home"
    home.mkdir()
    original = root / "original"
    original.write_text("original")
    target = home / ".config/sketchybar/test.lua"
    module.link(original, target)
    assert target.read_text() == "original"
    replacement = root / "replacement"
    replacement.write_text("replacement")
    module.link(replacement, target)
    assert target.read_text() == "replacement"
    manifest = root / "rollback.json"
    manifest.write_text(json.dumps([{"path": ".config/sketchybar/test.lua", "kind": "link", "target": str(original)}]))
    with patch.object(Path, "home", return_value=home):
        module.restore(manifest)
    assert target.read_text() == "original"
print("Bar deployment: restricted paths, atomic replacement and rollback passed")

with patch.object(module.subprocess, "run", return_value=Mock(returncode=0, stdout='{"label":{"value":"new"}}')):
    assert module.healthy("new") and not module.healthy("old")
with patch.object(module.subprocess, "run", return_value=Mock(returncode=0, stdout="invalid")):
    assert not module.healthy("new")
print("Bar deployment: generation-specific startup verification passed")
