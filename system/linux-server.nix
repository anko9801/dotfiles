# Server platform configuration
# Lightweight setup for remote servers
{ pkgs, lib, ... }:

{
  imports = [
    ../home/editor/vim.nix
    ../home/tools/git
    ../home/tools/cli.nix
    ../home/tools/bat.nix
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

    # Tmux for session management (prefix: Ctrl-q, same as zellij)
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "screen-256color";
      prefix = "C-q";
      extraConfig = ''
        # Unbind default prefix
        unbind C-b

        # Enable mouse
        set -g mouse on

        # Start windows and panes at 1
        set -g base-index 1
        setw -g pane-base-index 1

        # Vim-like pane navigation (same as zellij)
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Split panes (same as zellij: " for horizontal, % for vertical)
        bind '"' split-window -v
        bind '%' split-window -h
        bind '-' split-window -v
        bind '|' split-window -h

        # Window navigation
        bind c new-window
        bind n next-window
        bind p previous-window

        # Detach
        bind d detach-client
      '';
    };
  };
}
