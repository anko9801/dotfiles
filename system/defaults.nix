# Unified cross-cutting defaults
# Single source of truth for settings that affect multiple tools
{ lib, config, ... }:
let
  cfg = config.defaults;
in
{
  options.defaults = {
    # Editor
    editor = lib.mkOption {
      type = lib.types.str;
      default = "vim";
      description = "Default editor for EDITOR, VISUAL, git, etc.";
    };

    # Pager
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

    # Locale
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

    # Browser
    browser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default browser command";
    };

    # Terminal / Capabilities
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

    # Clipboard
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

    # Display
    display = {
      isHeadless = lib.mkOption {
        type = lib.types.bool;
        default = config.platform.isCI || (!config.platform.isDarwin && !config.platform.isLinuxDesktop);
        description = "Whether running in headless environment";
      };
    };

    # Privacy
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

    # Proxy (null = no proxy)
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

    # Identity (set from users.nix)
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

  config = {
    # === Environment Variables (merged) ===
    home.sessionVariables =
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
      };

    # === Programs ===
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
        character.success_symbol = "[>](green)";
        git_branch.symbol = "";
      };
    };
  };
}
