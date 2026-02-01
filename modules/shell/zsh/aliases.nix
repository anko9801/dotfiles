_:

{
  programs.zsh = {
    # Keep safety aliases (don't expand, just run)
    shellAliases = {
      rm = "trash";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
    };

    # Abbreviations (expand when typed) - zsh-abbr loaded as plugin in default.nix
    initContent = ''
      # ==============================================================================
      # Abbreviations (using zsh-abbr)
      # ==============================================================================
      # Modern CLI replacements
      abbr -S -q ls="eza"
      abbr -S -q ll="eza -l"
      abbr -S -q la="eza -la"
      abbr -S -q lt="eza --tree"
      abbr -S -q lta="eza --tree -a"
      abbr -S -q cat="bat"
      abbr -S -q find="fd"
      abbr -S -q grep="rg"
      abbr -S -q top="btm"
      abbr -S -q htop="btm"
      abbr -S -q du="dust"
      abbr -S -q ps="procs"
      abbr -S -q sed="sd"
      abbr -S -q df="df -h"
      abbr -S -q free="free -h"

      # Navigation
      abbr -S -q ..="cd .."
      abbr -S -q ...="cd ../.."
      abbr -S -q ....="cd ../../.."
      abbr -S -q dl="cd ~/Downloads"
      abbr -S -q dt="cd ~/Desktop"
      abbr -S -q pj="cd ~/repos"
      abbr -S -q dot="cd ~/dotfiles"

      # Git
      abbr -S -q g="git"
      abbr -S -q gst="git st"
      abbr -S -q gsw="git sw"
      abbr -S -q gf="git f"
      abbr -S -q gpl="git pl"
      abbr -S -q gps="git ps"
      abbr -S -q glg="git lg"
      abbr -S -q gla="git la"
      abbr -S -q gdf="git df"
      abbr -S -q gstaged="git staged"
      abbr -S -q gamend="git amend"
      abbr -S -q gundo="git undo"
      abbr -S -q gunstage="git unstage"
      abbr -S -q gcleanup="git cleanup"
      abbr -S -q gopen="git open"

      # Docker
      abbr -S -q d="docker"
      abbr -S -q dc="docker-compose"
      abbr -S -q dps="docker ps"
      abbr -S -q dpsa="docker ps -a"
      abbr -S -q di="docker images"
      abbr -S -q drm="docker rm"
      abbr -S -q drmi="docker rmi"

      # Editors
      abbr -S -q v="vim"
      abbr -S -q nv="nvim"
      abbr -S -q c="code"

      # zellij
      abbr -S -q zj="zellij"
      abbr -S -q zja="zellij attach"
      abbr -S -q zjn="zellij -s"
      abbr -S -q zjl="zellij list-sessions"
      abbr -S -q zjk="zellij kill-session"

      # Tools
      abbr -S -q lg="lazygit"

      # Development
      abbr -S -q py="python3"
      abbr -S -q pip="uv pip"
      abbr -S -q venv="uv venv"

      # GitHub CLI
      abbr -S -q ghpr="gh pr create"
      abbr -S -q ghpv="gh pr view"
      abbr -S -q ghpl="gh pr list"
      abbr -S -q ghrc="gh repo clone"
      abbr -S -q ghrv="gh repo view --web"

      # Misc
      abbr -S -q h="history"
      abbr -S -q j="jobs"
      abbr -S -q reload="source ~/.zshrc"

      # Ctrl+a: fzf で abbr 一覧から選択して挿入
      function _fzf_abbr() {
        local selected=$(abbr | fzf --height=40% --reverse | cut -d'=' -f1 | tr -d ' "')
        if [[ -n "$selected" ]]; then
          LBUFFER+="$selected "
          zle expand-abbr
        fi
        zle redisplay
      }
      zle -N _fzf_abbr
      bindkey '^a' _fzf_abbr
    '';
  };
}
