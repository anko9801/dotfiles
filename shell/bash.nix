# Minimal bash — zsh is the primary shell
{ config, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [ "ignoreboth" ];
    inherit (config.shell) historySize;
    historyFileSize = config.shell.historySize;
  };
}
