# Core home-manager configuration with platform detection
{
  lib,
  pkgs,
  config,
  versions,
  ...
}:

let
  # Create platform-specific value
  # Usage: mkPlatformValue config { default = ...; windows = ...; darwin = ...; }
  mkPlatformValue =
    cfg:
    {
      default,
      windows ? default,
      darwin ? default,
    }:
    if cfg.platform.isWindows then
      windows
    else if cfg.platform.isDarwin then
      darwin
    else
      default;
in
{
  options = {
    # Platform-aware utility function
    helpers.mkPlatformValue = lib.mkOption {
      type = lib.types.unspecified;
      default = mkPlatformValue;
      readOnly = true;
      description = "Create platform-specific value";
    };

    # WSL username (set in flake.nix for WSL configs)
    programs.wsl.windowsUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Windows username for WSL integration paths";
    };

    # Platform detection flags
    platform = {
      isCI = lib.mkOption {
        type = lib.types.bool;
        default = builtins.getEnv "CI" != "";
        readOnly = true;
        description = "Whether running in CI environment";
      };
      isWSL = lib.mkOption {
        type = lib.types.bool;
        default = config.programs.wsl.windowsUser != null;
        readOnly = true;
        description = "Whether running in WSL";
      };
      isDarwin = lib.mkOption {
        type = lib.types.bool;
        default = pkgs.stdenv.isDarwin;
        readOnly = true;
        description = "Whether running on macOS";
      };
      isLinux = lib.mkOption {
        type = lib.types.bool;
        default = pkgs.stdenv.isLinux;
        readOnly = true;
        description = "Whether running on Linux (includes WSL)";
      };
      isLinuxDesktop = lib.mkOption {
        type = lib.types.bool;
        default = pkgs.stdenv.isLinux && !config.platform.isWSL;
        readOnly = true;
        description = "Whether running on native Linux (not WSL)";
      };
      isWindows = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether generating config for Windows";
      };
      winAppsPath = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "/mnt/c/Users/${config.programs.wsl.windowsUser}/AppData/Local/Microsoft";
        description = "Windows AppData/Local/Microsoft path (WSL only)";
      };
      macAppsPath = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "/Applications";
        description = "macOS Applications path";
      };
    };
  };

  config = {
    home = {
      stateVersion = versions.home;
      sessionVariables.LANG = "ja_JP.UTF-8";
      sessionPath = [ "$HOME/.local/bin" ];
    };

    # Disable systemd user service management in CI (runner/activation user mismatch)
    systemd.user.startServices = if config.platform.isCI then false else "sd-switch";

    xdg.enable = true;
    programs.home-manager.enable = true;
  };
}
