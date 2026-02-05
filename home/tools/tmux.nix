# Tmux for session management on servers (prefix: Ctrl-q, same as zellij)
_:

{
  programs.tmux = {
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
}
