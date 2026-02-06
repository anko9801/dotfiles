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

    # Keybindings - Quick splits (macOS style)
    keybind = super+d=new_split:right
    keybind = super+shift+d=new_split:down

    # Keybindings - Pane navigation (vim-style with Ctrl-q prefix)
    keybind = ctrl+q>h=goto_split:left
    keybind = ctrl+q>j=goto_split:down
    keybind = ctrl+q>k=goto_split:up
    keybind = ctrl+q>l=goto_split:right
    keybind = ctrl+alt+h=goto_split:left
    keybind = ctrl+alt+l=goto_split:right
    keybind = ctrl+shift+j=goto_split:down
    keybind = ctrl+shift+k=goto_split:up

    # Keybindings - Split (tmux/zellij compatible)
    keybind = ctrl+q>minus=new_split:down
    keybind = ctrl+q>shift+quote=new_split:down
    keybind = ctrl+q>shift+backslash=new_split:right
    keybind = ctrl+q>shift+five=new_split:right
    keybind = ctrl+q>x=close_surface
    keybind = ctrl+q>z=toggle_split_zoom

    # Keybindings - Resize panes
    keybind = super+ctrl+left=resize_split:left,40
    keybind = super+ctrl+right=resize_split:right,40
    keybind = super+ctrl+up=resize_split:up,40
    keybind = super+ctrl+down=resize_split:down,40

    # Quick terminal (macOS)
    quick-terminal-position = center

    # Terminal input compatibility (Emacs-style)
    keybind = ctrl+m=text:\n
    keybind = ctrl+enter=text:\n
    keybind = ctrl+i=text:\t
  '';
}
