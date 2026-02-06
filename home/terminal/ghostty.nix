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

    # Quick splits (no prefix)
    keybind = super+d=new_split:right
    keybind = super+shift+d=new_split:down

    # Ctrl-q prefix (tmux-compatible)
    keybind = ctrl+q>h=goto_split:left
    keybind = ctrl+q>j=goto_split:down
    keybind = ctrl+q>k=goto_split:up
    keybind = ctrl+q>l=goto_split:right
    keybind = ctrl+q>minus=new_split:down
    keybind = ctrl+q>shift+backslash=new_split:right
    keybind = ctrl+q>x=close_surface
    keybind = ctrl+q>z=toggle_split_zoom
    keybind = ctrl+q>shift+h=resize_split:left,40
    keybind = ctrl+q>shift+j=resize_split:down,40
    keybind = ctrl+q>shift+k=resize_split:up,40
    keybind = ctrl+q>shift+l=resize_split:right,40

    # Quick terminal (macOS)
    quick-terminal-position = center

    # Terminal input compatibility (Emacs-style)
    keybind = ctrl+m=text:\n
    keybind = ctrl+enter=text:\n
    keybind = ctrl+i=text:\t
  '';
}
