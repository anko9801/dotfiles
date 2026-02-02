# Server platform configuration
# Lightweight setup for remote servers
{ pkgs, lib, ... }:

{
  imports = [
    ../editor/vim.nix
    ../tools/git
    ../tools/cli.nix
    ../tools/bat.nix
  ];

  home = {
    packages = with pkgs; [
      # Essential tools
      git
      curl
      wget
      htop
      tmux
      tree
      jq
      ripgrep
      fd

      # Network tools
      netcat
      dig
    ];

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  programs = {
    # Use Vim as default editor on servers
    vim.defaultEditor = true;

    # Basic shell setup
    bash = {
      enable = true;
      shellAliases = lib.mkForce {
        ll = "ls -la";
        la = "ls -A";
        l = "ls -CF";
        ".." = "cd ..";
        "..." = "cd ../..";
      };
    };

    # Git with minimal config
    git = {
      enable = true;
      settings = {
        core.editor = lib.mkForce "vim";
      };
    };

    # Tmux for session management
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "screen-256color";
      extraConfig = ''
        # Enable mouse
        set -g mouse on

        # Start windows and panes at 1
        set -g base-index 1
        setw -g pane-base-index 1

        # Vim-like pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Split panes with | and -
        bind | split-window -h
        bind - split-window -v
      '';
    };
  };
}
