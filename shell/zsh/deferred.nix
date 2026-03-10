# Deferred initialization for fast zsh startup
#
# Uses zsh-defer to load heavy tools after the prompt is displayed.
# Initialization order:
#   1. EARLY (cannot defer): zellij auto-attach, zsh-defer itself, starship
#   2. DEFERRED: GPG_TTY, compinit, fzf, direnv, zoxide, atuin
#   3. DEFERRED PLUGINS: fzf-tab, autosuggestions, fast-syntax-highlighting, zsh-abbr
{
  pkgs,
  lib,
  unfreePkgs,
  ...
}:

{
  programs.zsh = {
    syntaxHighlighting.enable = false;
    autosuggestion.enable = false;
    plugins = [ ];
    enableCompletion = false;
    completionInit = "";

    initContent = lib.mkBefore ''
      # Auto-start zellij (CANNOT DEFER: must attach before shell is ready)
      if [[ -z "$ZELLIJ" && -z "$INSIDE_EMACS" && -z "$VSCODE_TERMINAL" && -z "$CI" && -t 0 ]] && command -v zellij &>/dev/null; then
        zellij attach -c
      fi

      # zsh-defer: deferred execution for faster startup (CANNOT DEFER: other defers depend on it)
      source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh

      # Starship (CANNOT DEFER: breaks prompt display in zellij, causes visual glitches)
      [[ $TERM != "dumb" ]] && eval "$(${pkgs.starship}/bin/starship init zsh)"

      # Deferred initializer (single function to minimize zsh-defer overhead)
      _init_deferred() {
        export GPG_TTY=$(tty)
        autoload -Uz compinit
        if [[ -n ''${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
          compinit
        else
          compinit -C
        fi
        source <(${pkgs.fzf}/bin/fzf --zsh)
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd cd)"
        [[ $options[zle] = on ]] && eval "$(${pkgs.atuin}/bin/atuin init zsh)"
      }
      zsh-defer _init_deferred
      zsh-defer source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zsh-defer source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      zsh-defer source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
      zsh-defer source ${unfreePkgs.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.plugin.zsh
    '';
  };
}
