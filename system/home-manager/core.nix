# Core home-manager configuration with platform detection and defaults
{
  lib,
  pkgs,
  config,
  versions,
  userConfig,
  ...
}:

let
  cfg = config.defaults;

  # Create platform-specific value
  # Usage: mkPlatformValue config { default = ...; windows = ...; darwin = ...; }
  mkPlatformValue =
    c:
    {
      default,
      windows ? default,
      darwin ? default,
    }:
    if c.platform.isWindows then
      windows
    else if c.platform.isDarwin then
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

    # Cross-cutting defaults
    defaults = {
      editor = lib.mkOption {
        type = lib.types.str;
        default = "vim";
        description = "Default editor for EDITOR, VISUAL, git, etc.";
      };

      pager = {
        command = lib.mkOption {
          type = lib.types.str;
          default = "less";
          description = "Default pager command";
        };
        lessOptions = lib.mkOption {
          type = lib.types.str;
          default = "-R --quit-if-one-screen";
          description = "LESS options";
        };
      };

      locale = {
        lang = lib.mkOption {
          type = lib.types.str;
          default = "en_US.UTF-8";
          description = "LANG environment variable";
        };
        lc_time = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "LC_TIME override (null = use LANG)";
        };
      };

      browser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Default browser command";
      };

      terminal = {
        trueColor = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether terminal supports true color";
        };
        nerdFonts = lib.mkOption {
          type = lib.types.bool;
          default = !config.platform.isCI;
          description = "Whether Nerd Fonts are available";
        };
      };

      clipboard = lib.mkOption {
        type = lib.types.enum [
          "osc52"
          "wayland"
          "x11"
          "pbcopy"
          "wsl"
        ];
        default =
          if config.platform.isDarwin then
            "pbcopy"
          else if config.platform.isWSL then
            "wsl"
          else
            "osc52";
        description = "Clipboard provider";
      };

      display = {
        isHeadless = lib.mkOption {
          type = lib.types.bool;
          default = config.platform.isCI || (!config.platform.isDarwin && !config.platform.isLinuxDesktop);
          description = "Whether running in headless environment";
        };
      };

      privacy = {
        disableTelemetry = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Disable telemetry in all tools";
        };
        historySize = lib.mkOption {
          type = lib.types.int;
          default = 10000;
          description = "History size for shells";
        };
      };

      proxy = {
        http = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "HTTP proxy URL";
        };
        https = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "HTTPS proxy URL";
        };
        noProxy = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "localhost"
            "127.0.0.1"
          ];
          description = "Hosts to bypass proxy";
        };
      };

      identity = {
        name = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Full name for git, etc.";
        };
        email = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Email for git, etc.";
        };
        signingKey = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "GPG signing key ID";
        };
        sshKey = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "SSH public key for git signing";
        };
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

      sessionVariables =
        # Editor (mkDefault to allow nixvim etc. to override)
        {
          EDITOR = lib.mkDefault cfg.editor;
          VISUAL = lib.mkDefault cfg.editor;
        }
        # Pager
        // {
          PAGER = cfg.pager.command;
          LESS = cfg.pager.lessOptions;
        }
        # Locale
        // {
          LANG = cfg.locale.lang;
        }
        // lib.optionalAttrs (cfg.locale.lc_time != null) {
          LC_TIME = cfg.locale.lc_time;
        }
        # Browser
        // lib.optionalAttrs (cfg.browser != null) {
          BROWSER = cfg.browser;
        }
        # Terminal
        // lib.optionalAttrs cfg.terminal.trueColor {
          COLORTERM = "truecolor";
        }
        # Privacy / Telemetry
        // lib.optionalAttrs cfg.privacy.disableTelemetry {
          DO_NOT_TRACK = "1";
          DOTNET_CLI_TELEMETRY_OPTOUT = "1";
          HOMEBREW_NO_ANALYTICS = "1";
          SAM_CLI_TELEMETRY = "0";
          AZURE_CORE_COLLECT_TELEMETRY = "0";
          GATSBY_TELEMETRY_DISABLED = "1";
          NEXT_TELEMETRY_DISABLED = "1";
        }
        # Proxy
        // lib.optionalAttrs (cfg.proxy.http != null) {
          HTTP_PROXY = cfg.proxy.http;
          http_proxy = cfg.proxy.http;
        }
        // lib.optionalAttrs (cfg.proxy.https != null) {
          HTTPS_PROXY = cfg.proxy.https;
          https_proxy = cfg.proxy.https;
        }
        // lib.optionalAttrs (cfg.proxy.http != null || cfg.proxy.https != null) {
          NO_PROXY = lib.concatStringsSep "," cfg.proxy.noProxy;
          no_proxy = lib.concatStringsSep "," cfg.proxy.noProxy;
        }
        # Platform-specific
        // lib.optionalAttrs config.platform.isWSL {
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

      git = {
        settings = {
          core = {
            editor = lib.mkDefault cfg.editor;
            pager = lib.mkDefault cfg.pager.command;
          };
          user = {
            name = lib.mkIf (cfg.identity.name != null) cfg.identity.name;
            email = lib.mkIf (cfg.identity.email != null) cfg.identity.email;
          };
        };
        signing = lib.mkIf (cfg.identity.signingKey != null) {
          key = cfg.identity.signingKey;
          signByDefault = true;
        };
      };

      zsh.history.size = cfg.privacy.historySize;
      bash.historySize = cfg.privacy.historySize;

      starship.settings = lib.mkIf (config.programs.starship.enable && !cfg.terminal.nerdFonts) {
        character.success_symbol = lib.mkDefault "[>](green)";
        git_branch.symbol = lib.mkDefault "";
      };
    };
  };
}
