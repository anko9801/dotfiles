{ config, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    historyControl = [
      "ignoreboth"
    ];
    inherit (config.shell) historySize;
    historyFileSize = config.shell.historySize;

    shellOptions = [
      "histappend"
      "checkwinsize"
    ];

    # Minimal bashrc - zsh is the primary shell
    initExtra = ''
      # Color support
      if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
      fi
    '';
  };
}
