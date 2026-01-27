{
  lib,
  ...
}:

{
  imports = [
    ./modules/shell
    ./modules/tools
    ./modules/services
  ];

  home = {
    username = "anko";
    homeDirectory = lib.mkDefault "/home/anko";
    stateVersion = "24.11";

    sessionVariables = {
      # Locale
      LANG = "ja_JP.UTF-8";

      # Editors (nixvim sets EDITOR via defaultEditor)
      PAGER = "less";
      LESSHISTFILE = "-";

      # Readline config
      INPUTRC = "$XDG_CONFIG_HOME/readline/inputrc";

      # Development
      GOPATH = "$HOME/go";
      NODE_OPTIONS = "--max-old-space-size=4096";
      PYTHONUNBUFFERED = "1";

      # FZF
      FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";
      FZF_CTRL_T_COMMAND = "fd --type f --hidden --follow --exclude .git";

      # Suppress zoxide doctor warning
      _ZO_DOCTOR = "0";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "$HOME/.cargo/bin"
      "$HOME/.npm-global/bin"
    ];

    activation.installNpmPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if command -v npm &>/dev/null; then
        $DRY_RUN_CMD npm install -g @antfu/ni @anthropic-ai/claude-code @google/gemini-cli czg cz-git 2>/dev/null || true
      fi
    '';
  };

  xdg = {
    enable = true;
    configFile = {
      claude = {
        source = ./configs/claude;
        recursive = true;
      };
      wsl = {
        source = ./configs/wsl;
        recursive = true;
      };
    };
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
