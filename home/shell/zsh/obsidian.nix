{ lib, ... }:

{
  # Obsidian functions loaded from external script
  # Note: Uses `jq` from PATH (installed via cli.nix)
  programs.zsh.initContent = lib.mkMerge [
    (builtins.readFile ./scripts/obsidian.zsh)
  ];
}
