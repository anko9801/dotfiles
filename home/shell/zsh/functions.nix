# Shell utility functions
# Loaded from external script with @FZF_FLAGS@ placeholder replaced
{ lib, config, ... }:

let
  fzfFlags = config.shell.fzf.defaultFlags;
  script = builtins.readFile ./scripts/functions.zsh;
in
{
  programs.zsh.initContent = lib.mkMerge [
    (builtins.replaceStrings [ "@FZF_FLAGS@" ] [ fzfFlags ] script)
  ];
}
