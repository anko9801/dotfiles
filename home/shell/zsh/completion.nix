{ lib, ... }:

{
  # Completion styles loaded from external script for proper syntax highlighting
  programs.zsh.initContent = lib.mkMerge [
    (builtins.readFile ./scripts/completion.zsh)
  ];
}
