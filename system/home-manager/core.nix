# Core home-manager configuration with platform detection
{
  lib,
  pkgs,
  config,
  versions,
  userConfig,
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
    # Enable generic Linux target for non-NixOS Linux
    targets.genericLinux.enable = config.platform.isLinux;

    # Platform-specific defaults + user identity
    defaults = {
      locale.lang = "ja_JP.UTF-8";
      browser = lib.mkIf config.platform.isWSL "xdg-open";
      identity = {
        name = userConfig.git.name or userConfig.name or null;
        email = userConfig.git.email or userConfig.email or null;
        signingKey = userConfig.git.signingKey or userConfig.signingKey or null;
        sshKey = userConfig.git.sshKey or userConfig.sshKey or "";
      };
    };

    home = {
      stateVersion = versions.home;
      # Platform-specific env vars (not covered by defaults.nix)
      sessionVariables =
        lib.optionalAttrs config.platform.isWSL {
          DISPLAY = ":0";
          WSL_INTEROP = "/run/WSL/1_interop";
        }
        // lib.optionalAttrs config.platform.isLinuxDesktop {
          MOZ_ENABLE_WAYLAND = "1";
          QT_QPA_PLATFORM = "wayland;xcb";
        };
      sessionPath = [
        "$HOME/.local/bin"
      ]
      ++ lib.optionals config.platform.isDarwin [
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
      ];

      # WSL: Docker CLI plugins (for Docker Desktop integration)
      file = lib.mkIf config.platform.isWSL {
        ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";
        ".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";
      };

      # WSL: xdg-open browser setup
      activation = lib.mkIf config.platform.isWSL {
        setupXdgOpen = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
            $DRY_RUN_CMD mkdir -p $HOME/.local/share/applications
            cat > $HOME/.local/share/applications/wslview.desktop << 'DESKTOP'
          [Desktop Entry]
          Type=Application
          Version=1.0
          Name=WSL Browser
          NoDisplay=true
          Exec=wslview %u
          MimeType=x-scheme-handler/http;x-scheme-handler/https;
          DESKTOP
            $DRY_RUN_CMD xdg-settings set default-web-browser wslview.desktop 2>/dev/null || true
          fi
        '';
      };
    };

    # Disable systemd user service management in CI (runner/activation user mismatch)
    systemd.user.startServices = if config.platform.isCI then false else "sd-switch";

    xdg.enable = true;

    programs = {
      home-manager.enable = true;
      bash.enable = lib.mkDefault true;
    };
  };
}
