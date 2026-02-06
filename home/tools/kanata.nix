# Kanata - Cross-platform key remapper
# https://github.com/jtroo/kanata
# Shared configuration for Linux (NixOS) and macOS (nix-darwin)
# Note: Does NOT work on WSL (no access to input devices)
_:

let
  kanataConfig = import ./kanata-config.nix;
in
{
  # Generate Kanata config file at ~/.config/kanata/kanata.kbd
  xdg.configFile."kanata/kanata.kbd".text = kanataConfig;
}
