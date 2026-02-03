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

    # Keybindings (vim-style pane navigation with Ctrl-s prefix)
    keybind = ctrl+s>h=goto_split:left
    keybind = ctrl+s>j=goto_split:down
    keybind = ctrl+s>k=goto_split:up
    keybind = ctrl+s>l=goto_split:right
    keybind = ctrl+s>v=new_split:right
    keybind = ctrl+s>s=new_split:down
    keybind = ctrl+s>x=close_surface
    keybind = ctrl+s>z=toggle_split_zoom

    # Quick terminal (macOS)
    quick-terminal-position = center

    # Terminal input compatibility (Emacs-style)
    keybind = ctrl+m=text:\n
    keybind = ctrl+enter=text:\n
    keybind = ctrl+i=text:\t
  '';
}
