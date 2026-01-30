{
  pkgs,
  ...
}:

{
  # zsh-abbr for abbreviations (expand on space/enter)
  programs.zsh = {
    # Keep safety aliases (don't expand, just run)
    shellAliases = {
      rm = "trash";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
    };

    # Abbreviations (expand when typed)
    initContent = ''
      # ==============================================================================
      # Abbreviations (using zsh-abbr)
      # ==============================================================================
      if (( $+commands[abbr] )); then
        # Modern CLI replacements
        abbr -S ls="eza" 2>/dev/null
        abbr -S ll="eza -l" 2>/dev/null
        abbr -S la="eza -la" 2>/dev/null
        abbr -S lt="eza --tree" 2>/dev/null
        abbr -S lta="eza --tree -a" 2>/dev/null
        abbr -S cat="bat" 2>/dev/null
        abbr -S find="fd" 2>/dev/null
        abbr -S grep="rg" 2>/dev/null
        abbr -S top="btm" 2>/dev/null
        abbr -S htop="btm" 2>/dev/null
        abbr -S du="dust" 2>/dev/null
        abbr -S ps="procs" 2>/dev/null
        abbr -S sed="sd" 2>/dev/null
        abbr -S df="df -h" 2>/dev/null
        abbr -S free="free -h" 2>/dev/null

        # Navigation
        abbr -S ..="cd .." 2>/dev/null
        abbr -S ...="cd ../.." 2>/dev/null
        abbr -S ....="cd ../../.." 2>/dev/null
        abbr -S dl="cd ~/Downloads" 2>/dev/null
        abbr -S dt="cd ~/Desktop" 2>/dev/null
        abbr -S pj="cd ~/repos" 2>/dev/null
        abbr -S dot="cd ~/dotfiles" 2>/dev/null

        # Git
        abbr -S g="git" 2>/dev/null
        abbr -S gst="git st" 2>/dev/null
        abbr -S gsw="git sw" 2>/dev/null
        abbr -S gf="git f" 2>/dev/null
        abbr -S gpl="git pl" 2>/dev/null
        abbr -S gps="git ps" 2>/dev/null
        abbr -S glg="git lg" 2>/dev/null
        abbr -S gla="git la" 2>/dev/null
        abbr -S gdf="git df" 2>/dev/null
        abbr -S gstaged="git staged" 2>/dev/null
        abbr -S gamend="git amend" 2>/dev/null
        abbr -S gundo="git undo" 2>/dev/null
        abbr -S gunstage="git unstage" 2>/dev/null
        abbr -S gcleanup="git cleanup" 2>/dev/null
        abbr -S gopen="git open" 2>/dev/null
        abbr -S gc="ghq get" 2>/dev/null

        # Docker
        abbr -S d="docker" 2>/dev/null
        abbr -S dc="docker-compose" 2>/dev/null
        abbr -S dps="docker ps" 2>/dev/null
        abbr -S dpsa="docker ps -a" 2>/dev/null
        abbr -S di="docker images" 2>/dev/null
        abbr -S drm="docker rm" 2>/dev/null
        abbr -S drmi="docker rmi" 2>/dev/null

        # Editors
        abbr -S v="vim" 2>/dev/null
        abbr -S nv="nvim" 2>/dev/null
        abbr -S c="code" 2>/dev/null

        # zellij
        abbr -S zj="zellij" 2>/dev/null
        abbr -S zja="zellij attach" 2>/dev/null
        abbr -S zjn="zellij -s" 2>/dev/null
        abbr -S zjl="zellij list-sessions" 2>/dev/null
        abbr -S zjk="zellij kill-session" 2>/dev/null

        # Tools
        abbr -S lg="lazygit" 2>/dev/null

        # Development
        abbr -S py="python3" 2>/dev/null
        abbr -S pip="uv pip" 2>/dev/null
        abbr -S venv="uv venv" 2>/dev/null

        # GitHub CLI
        abbr -S ghpr="gh pr create" 2>/dev/null
        abbr -S ghpv="gh pr view" 2>/dev/null
        abbr -S ghpl="gh pr list" 2>/dev/null
        abbr -S ghrc="gh repo clone" 2>/dev/null
        abbr -S ghrv="gh repo view --web" 2>/dev/null

        # ghq
        abbr -S gql="ghq list" 2>/dev/null
        abbr -S gqr="ghq root" 2>/dev/null

        # Misc
        abbr -S h="history" 2>/dev/null
        abbr -S j="jobs" 2>/dev/null
        abbr -S reload="source ~/.zshrc" 2>/dev/null
      fi
    '';
  };

  # Install zsh-abbr
  home.packages = [ pkgs.zsh-abbr ];
}
