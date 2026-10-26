#!/usr/bin/env python3
"""Evaluate keyboard module contracts without starting input capture or a full flake."""
import json
import os
from pathlib import Path
import re
import subprocess

root = Path(__file__).resolve().parents[1]
expression = r'''
let
  module = import ./desktop/kanata.nix;
  darwin = module.darwinModule { username = "fixture"; pkgs.writeTextFile = value: value; };
  defaults = import ./system/darwin/defaults.nix {
    config.system.primaryUser = "fixture";
    pkgs = {};
  };
in {
  startsKanata = darwin.launchd.daemons ? kanata;
  capsIsControl = defaults.system.keyboard.remapCapsLockToControl;
  fnUsage = defaults.system.defaults.CustomUserPreferences.NSGlobalDomain.AppleFnUsageType;
  functionRow = defaults.system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.keyboard.fnState";
  macos = darwin.home-manager.users.fixture.xdg.configFile."kanata/kanata.kbd".text;
  linux = module.linuxConfig;
  windows = module.windowsConfig;
}
'''
result = subprocess.run(
    [os.environ.get("NIX_INSTANTIATE", "nix-instantiate"), "--eval", "--strict", "--json", "--expr", expression],
    cwd=root, check=True, capture_output=True, text=True, timeout=15,
)
config = json.loads(result.stdout)
assert not config["startsKanata"], "macOS must not start the keyboard capture that broke physical Fn"
assert config["capsIsControl"] and config["fnUsage"] == 0 and config["functionRow"]
assert not re.search(r"\b(eisu|kana|lmet|rmet)\b", config["macos"]), "Manual macOS config must not remap Command taps"
assert all(key in config["linux"] for key in ("muhenkan", "henkan", "@lm @rm"))
assert all(key in config["windows"] for key in ("eisu", "kana", "@lm @rm"))
print("Keyboard modules: native macOS Fn/Command, Caps-Control, and unchanged Linux/Windows input mappings passed")
