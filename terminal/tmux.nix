# Tmux for session management on servers (prefix: Ctrl-q, same as zellij)
_:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
    prefix = "C-q";
    escapeTime = 0;
    extraConfig = ''
      # Unbind default prefix
      unbind C-b

      # Enable mouse
      set -g mouse on

      # Start windows and panes at 1, renumber on close
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on

      # Resize panes to largest attached client
      setw -g aggressive-resize on

      # Vim-like pane navigation (same as zellij)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Split panes (inherit current path)
      bind '"' split-window -v -c "#{pane_current_path}"
      bind '%' split-window -h -c "#{pane_current_path}"
      bind '-' split-window -v -c "#{pane_current_path}"
      bind '|' split-window -h -c "#{pane_current_path}"

      # New window inherits current path
      bind c new-window -c "#{pane_current_path}"
      bind n next-window
      bind p previous-window

      # Vi copy-mode with clipboard
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel

      # Detach
      bind d detach-client
    '';
  };
}
