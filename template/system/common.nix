# Common home-manager configuration for all hosts
# Platform detection, shared defaults, and HM bootstrap
{
  lib,
  pkgs,
  config,
  userConfig,
  ...
}:
let
  cfg = config.defaults;
in
{
  # ── Option declarations ──────────────────────────────────────────────────
  options.defaults = {
    identity = {
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Full name (used by git, etc.)";
      };
      email = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Email address (used by git, etc.)";
      };
    };

    editor = lib.mkOption {
      type = lib.types.str;
      default = "vim";
      description = "Default editor";
    };
  };

  # ── Configuration ────────────────────────────────────────────────────────
  config = {
    # Wire userConfig into defaults
    defaults.identity = {
      name = userConfig.userName or null;
      email = userConfig.userEmail or null;
    };

    home = {
      stateVersion = "24.11";
      preferXdgDirectories = true;

      sessionVariables = {
        EDITOR = lib.mkDefault cfg.editor;
        VISUAL = lib.mkDefault cfg.editor;
      };
    };

    # Platform integration
    targets.genericLinux.enable = pkgs.stdenv.isLinux;
    xdg.enable = true;

    programs.home-manager.enable = true;
  };
}
