# Ghostty terminal emulator settings
# Theming is handled by Stylix, this adds extra functionality
_:

{
  # Ghostty config (Stylix handles colors/fonts)
  xdg.configFile."ghostty/config".text = ''
    # Window behavior
    window-save-state = always
    window-decoration = false
    confirm-close-surface = false

    # Font rendering
    font-thicken = true

    # Clipboard
    copy-on-select = clipboard

    # Keybindings (vim-style pane navigation with Ctrl-q prefix, same as zellij/tmux)
    keybind = ctrl+q>h=goto_split:left
    keybind = ctrl+q>j=goto_split:down
    keybind = ctrl+q>k=goto_split:up
    keybind = ctrl+q>l=goto_split:right
    keybind = ctrl+q>v=new_split:right
    keybind = ctrl+q>s=new_split:down
    keybind = ctrl+q>x=close_surface
    keybind = ctrl+q>z=toggle_split_zoom

    # Quick terminal (macOS)
    quick-terminal-position = center

    # Terminal input compatibility (Emacs-style)
    keybind = ctrl+m=text:\n
    keybind = ctrl+enter=text:\n
    keybind = ctrl+i=text:\t
  '';
}
