# Terminal emulators and multiplexers
# - ghostty: Modern terminal emulator
# - tmux: Session manager for servers
# - zellij: Modern terminal multiplexer (imported separately per platform)
_:

{
  imports = [
    ./ghostty.nix
    ./tmux.nix
    # zellij: imported separately in platform configs (WSL uses it, macOS uses Ghostty splits)
  ];
}
