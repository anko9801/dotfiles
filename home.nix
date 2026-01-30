{
  ...
}:

{
  imports = [
    ./modules/shell
    ./modules/tools
    ./modules/services
  ];

  home = {
    # username and homeDirectory are set in flake.nix
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

    # claude-code is managed via programs.claude-code in modules/tools/claude.nix
    # npm tools managed by mise
  };

  xdg.enable = true;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
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
