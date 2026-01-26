{
  config,
  pkgs,
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

    # Environment variables
    sessionVariables = {
      LANG = "ja_JP.UTF-8";
      EDITOR = lib.mkDefault "vim";
      VISUAL = lib.mkDefault "vim";
      PAGER = "less";
      LESSHISTFILE = "-";

      # XDG Base Directory
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";

      # Vim XDG support
      VIMINIT = ''let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'';
      INPUTRC = "$XDG_CONFIG_HOME/readline/inputrc";

      # Development
      GOPATH = "$HOME/go";

      # FZF
      FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";
      FZF_CTRL_T_COMMAND = "fd --type f --hidden --follow --exclude .git";

      # Node.js
      NODE_OPTIONS = "--max-old-space-size=4096";

      # Python
      PYTHONUNBUFFERED = "1";

      # Suppress zoxide doctor warning
      _ZO_DOCTOR = "0";
    };

    # PATH
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "$HOME/.cargo/bin"
      "$HOME/.npm-global/bin"
    ];

    # npm global packages installation via activation script
    activation = {
      installNpmPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if command -v npm &>/dev/null; then
          $DRY_RUN_CMD npm install -g @antfu/ni @anthropic-ai/claude-code @google/gemini-cli czg cz-git 2>/dev/null || true
        fi
      '';
    };
  };

  # Config files managed by Home Manager
  xdg.configFile = {
    "nvim" = {
      source = ./configs/nvim;
      recursive = true;
    };
    "vim" = {
      source = ./configs/vim;
      recursive = true;
    };
    "claude" = {
      source = ./configs/claude;
      recursive = true;
    };
    "wsl" = {
      source = ./configs/wsl;
      recursive = true;
    };
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable nix-direnv for better direnv integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # zoxide - smarter cd command
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  # fzf - fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
