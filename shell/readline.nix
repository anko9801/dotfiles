{ config, ... }:

{
  home.sessionVariables.INPUTRC = "${config.xdg.configHome}/readline/inputrc";

  programs.readline = {
    enable = true;
    variables = {
      editing-mode = "vi";
      show-mode-in-prompt = true;
      vi-ins-mode-string = "\\1\\e[6 q\\2";
      vi-cmd-mode-string = "\\1\\e[2 q\\2";
      bell-style = "none";
      completion-ignore-case = true;
      completion-map-case = true;
      show-all-if-ambiguous = true;
      mark-symlinked-directories = true;
      colored-stats = true;
      visible-stats = true;
    };
  };
}
