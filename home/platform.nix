# Centralized platform detection
# Use config.platform.isWSL, config.platform.isDarwin, config.platform.isLinux
{
  lib,
  pkgs,
  config,
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

    # Platform detection flags (computed from above + stdenv)
    platform = {
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
}
