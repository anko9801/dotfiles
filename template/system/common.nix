# Common home-manager configuration for all hosts
# Platform detection, shared defaults, and HM bootstrap
{
  lib,
  pkgs,
  config,
  userConfig,
  hostConfig,
  ...
}:
let
  cfg = config.defaults;
  p = config.platform;
in
{
  # ── Option declarations ──────────────────────────────────────────────────
  options.platform = {
    os = lib.mkOption {
      type = lib.types.enum [
        "darwin"
        "linux"
        "windows"
      ];
      readOnly = true;
      default = hostConfig.os or (if pkgs.stdenv.isDarwin then "darwin" else "linux");
      description = "Operating system (can be overridden via hostConfig.os)";
    };

    environment = lib.mkOption {
      type = lib.types.enum [
        "native"
        "wsl"
        "ci"
      ];
      readOnly = true;
      default =
        if builtins.getEnv "CI" != "" then
          "ci"
        else if builtins.pathExists /proc/sys/fs/binfmt_misc/WSLInterop then
          "wsl"
        else
          "native";
      description = "Execution environment";
    };
  };

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
        DO_NOT_TRACK = "1";
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    # Platform integration
    targets.genericLinux.enable = p.os == "linux";
    fonts.fontconfig.enable = p.os == "linux";
    systemd.user.startServices = if p.environment == "ci" then false else "sd-switch";
    xdg.enable = true;

    manual = {
      manpages.enable = false;
      html.enable = false;
      json.enable = false;
    };

    programs.home-manager.enable = true;
  };
}
