# Configuration: users, hosts, and modules
#
# Edit this file to customize your environment.
# After changes, run: nix run .#switch
{
  # ── Users ──────────────────────────────────────────────────────────────────
  # Add your identity here. Git, SSH, and other tools read from this.
  users = {
    # Replace with your username (must match $USER)
    your-username = {
      userName = "Your Name";
      userEmail = "you@example.com";
    };

    # CI fallback (do not remove)
    runner = {
      userName = "CI";
      userEmail = "ci@localhost";
    };
  };

  # ── Modules ────────────────────────────────────────────────────────────────
  # coreModules: always loaded for every host (keep minimal)
  coreModules = [
    ./system/common.nix
    ./shell/bash.nix
  ];

  # baseModules: standard set for interactive use
  baseModules = [
    ./theme/default.nix
    ./shell/starship.nix
    ./tools/git.nix
    ./editor/vim.nix
  ];

  # ── Hosts ──────────────────────────────────────────────────────────────────
  # Each host produces a homeConfigurations.<name> output.
  # system: "x86_64-linux" | "aarch64-linux" | "x86_64-darwin" | "aarch64-darwin"
  # os: "linux" | "darwin" | "windows" (default: auto-detected from system)
  hosts = {
    default = {
      system = "x86_64-linux";
    };
    # Windows (build on Linux, deploy via `nix run .#windows`)
    # windows = {
    #   system = "x86_64-linux";
    #   os = "windows";
    # };
    # mac = {
    #   system = "aarch64-darwin";
    #   modules = [];  # extra modules on top of baseModules
    # };
  };

  # Default host per platform (used by `nix run .#switch`)
  defaultHosts = {
    linux = "default";
    wsl = "default";
    darwin = "default";
  };
}
