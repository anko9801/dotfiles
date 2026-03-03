# Platform detection options and cross-cutting defaults
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

  isWsl = builtins.pathExists /proc/sys/fs/binfmt_misc/WSLInterop;
in
{
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
          default = "en_US.UTF-8";
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
        historySize = lib.mkOption {
          type = lib.types.int;
          default = 10000;
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
        signingKey = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        sshKey = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };
    };
  };

  config = {
    defaults = {
      locale.lang = "ja_JP.UTF-8";
      identity = {
        name = userConfig.git.name or userConfig.name or null;
        email = userConfig.git.email or userConfig.email or null;
        signingKey = userConfig.git.signingKey or userConfig.signingKey or null;
        sshKey = userConfig.git.sshKey or userConfig.sshKey or "";
      };
    };

    home.sessionVariables = {
      EDITOR = lib.mkDefault cfg.editor;
      VISUAL = lib.mkDefault cfg.editor;
      PAGER = cfg.pager.command;
      LESS = cfg.pager.lessOptions;
      LANG = cfg.locale.lang;
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

    home.sessionPath = [
      "$HOME/.local/bin"
    ]
    ++ lib.optionals (p.os == "darwin") [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    programs = {
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
