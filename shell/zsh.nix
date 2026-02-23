# Zsh — primary interactive shell
{ config, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = config.shell.historySize;
      save = config.shell.historySize;
      extended = true;
      share = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      ignorePatterns = map (p: "${p} *") config.shell.historyIgnorePatterns;
    };

    initContent = ''
      # Completion
      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD

      # Globbing
      setopt EXTENDED_GLOB
      setopt GLOBDOTS
      setopt NONOMATCH

      # Input
      setopt INTERACTIVE_COMMENTS
      setopt NO_BEEP

      # History
      setopt HIST_VERIFY
      setopt HIST_REDUCE_BLANKS

      # Local overrides
      [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
    '';
  };
}
