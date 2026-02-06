_:

{
  programs.zsh = {
    shellAliases = {
      lta = "eza --tree -a";
    };

    # Abbreviations loaded from external script for proper syntax highlighting
    initContent = builtins.readFile ./scripts/abbr.zsh;
  };
}
