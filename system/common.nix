# Common home-manager configuration for all hosts
# Platform detection, shared defaults, environment wiring, and HM bootstrap
{
  lib,
  pkgs,
  config,
  inputs,
  versions,
  userConfig,
  hostConfig,
  ...
}:

let
  cfg = config.defaults;
  p = config.platform;

  isWsl = builtins.pathExists /proc/sys/fs/binfmt_misc/WSLInterop;
  nixglPkgs = inputs.nixgl.packages.${pkgs.stdenv.hostPlatform.system} or null;
in
{
  # --- Option declarations ---

  options = {
    platform = {
      os = lib.mkOption {
        type = lib.types.enum [
          "darwin"
          "linux"
          "windows"
        ];
        readOnly = true;
        default = hostConfig.os or (if pkgs.stdenv.isDarwin then "darwin" else "linux");
        description = "Operating system (can be overridden in host config)";
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
          else if isWsl then
            "wsl"
          else
            "native";
        description = "Execution environment";
      };

      hasNativeGui = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        default = !(config.targets.genericLinux.enable or false);
        description = "True on platforms where native GUI applications can run (macOS, NixOS desktop)";
      };

      macAppsPath = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default = "/Applications";
        description = "macOS Applications path";
      };
    };

    defaults = {
      editor = lib.mkOption {
        type = lib.types.str;
        default = "vim";
        description = "Default editor";
      };

      pager = {
        command = lib.mkOption {
          type = lib.types.str;
          default = "less";
        };
        lessOptions = lib.mkOption {
          type = lib.types.str;
          default = "-R --quit-if-one-screen";
        };
      };

      locale = {
        lang = lib.mkOption {
          type = lib.types.str;
          default = "ja_JP.UTF-8";
        };
        lc_time = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };

      browser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      terminal = {
        trueColor = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        nerdFonts = lib.mkOption {
          type = lib.types.bool;
          default = p.environment != "ci";
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
          if p.os == "darwin" then
            "pbcopy"
          else if p.environment == "wsl" then
            "wsl"
          else
            "osc52";
      };

      privacy = {
        disableTelemetry = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };

      proxy = {
        http = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        https = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        noProxy = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "localhost"
            "127.0.0.1"
          ];
        };
      };

      identity = {
        name = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        email = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        sshKey = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      ssh = {
        agentSocket = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Path to SSH agent socket (set by credential provider)";
        };
        signProgram = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Path to SSH signing program (set by credential provider)";
        };
      };
    };
  };

  # --- Configuration ---

  config = {
    # Identity from userConfig
    defaults = {
      browser = lib.mkIf (p.environment == "wsl") "xdg-open";
      identity = {
        name = userConfig.git.name or userConfig.name or null;
        email = userConfig.git.email or userConfig.email or null;
        sshKey = userConfig.git.sshKey or userConfig.sshKey or "";
      };
    };

    # HM bootstrap
    home = {
      stateVersion = versions.home;
      preferXdgDirectories = true;

      sessionVariables = {
        EDITOR = lib.mkDefault cfg.editor;
        VISUAL = lib.mkDefault cfg.editor;
        PAGER = cfg.pager.command;
        LESS = cfg.pager.lessOptions;
        LANG = cfg.locale.lang;
        LOCALE_ARCHIVE = lib.mkIf (p.os == "linux") "${pkgs.glibcLocales}/lib/locale/locale-archive";
      }
      // lib.optionalAttrs (cfg.locale.lc_time != null) {
        LC_TIME = cfg.locale.lc_time;
      }
      // lib.optionalAttrs (cfg.browser != null) {
        BROWSER = cfg.browser;
      }
      // lib.optionalAttrs cfg.terminal.trueColor {
        COLORTERM = "truecolor";
      }
      // lib.optionalAttrs cfg.privacy.disableTelemetry {
        DO_NOT_TRACK = "1";
        DOTNET_CLI_TELEMETRY_OPTOUT = "1";
        HOMEBREW_NO_ANALYTICS = "1";
        SAM_CLI_TELEMETRY = "0";
        AZURE_CORE_COLLECT_TELEMETRY = "0";
        GATSBY_TELEMETRY_DISABLED = "1";
        NEXT_TELEMETRY_DISABLED = "1";
        STORYBOOK_DISABLE_TELEMETRY = "1";
        EXPO_NO_TELEMETRY = "1";
      }
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
      // lib.optionalAttrs (p.environment == "wsl") {
        DISPLAY = ":0";
        WSL_INTEROP = "/run/WSL/1_interop";
      };

      packages =
        let
          # Inputs with local paths that may not exist on all machines
          excludedInputs = [
            "nix-windows"
            "self"
          ];
          safeInputs = lib.filterAttrs (name: _: !(builtins.elem name excludedInputs)) inputs;
        in
        lib.mkIf (p.environment != "ci") [
          (pkgs.linkFarm "flake-inputs" (
            lib.mapAttrsToList (name: input: {
              inherit name;
              path = input.outPath;
            }) (lib.filterAttrs (_: v: v ? outPath) safeInputs)
          ))
        ];

      sessionPath = [
        "$HOME/.local/bin"
      ]
      ++ lib.optionals (p.os == "darwin") [
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
      ];

      # WSL: Docker CLI plugins
      file = lib.mkIf (p.environment == "wsl") {
        ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";
        ".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";
      };

      # WSL: xdg-open browser setup
      activation = lib.mkIf (p.environment == "wsl") {
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

    nixpkgs.config.allowUnfree = true;

    # Platform integration
    targets.genericLinux.enable = p.os == "linux";
    targets.genericLinux.nixGL = lib.mkIf (p.os == "linux" && nixglPkgs != null) {
      packages = nixglPkgs;
      defaultWrapper = "mesa";
      installScripts = [ "mesa" ];
    };
    fonts.fontconfig.enable = p.os == "linux";

    systemd.user.startServices = if p.environment == "ci" then false else "sd-switch";
    xdg.enable = true;

    manual = {
      manpages.enable = false;
      html.enable = false;
      json.enable = false;
    };

    # Program defaults
    programs = {
      home-manager.enable = true;
      bash.enable = lib.mkDefault true;
    };
  };
}
