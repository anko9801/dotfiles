# coreModule: minimal bash configuration
_: {
  programs.bash = {
    enable = true;
    enableCompletion = true;

    historyControl = [ "ignoreboth" ];
    historySize = 10000;
    historyFileSize = 10000;

    shellOptions = [
      "histappend"
      "checkwinsize"
    ];

    initExtra = ''
      # Color support
      if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
      fi
    '';
  };
}
