# Core home-manager configuration with platform detection
{
  lib,
  pkgs,
  config,
  versions,
  ...
}:

{
  options = {
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
