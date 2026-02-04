_:

{
  programs.zsh = {
    # Keep safety aliases (don't expand, just run)
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      lta = "eza --tree -a";
      cat = "bat";
      rm = "trash";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
    };

    # Abbreviations (expand when typed) - deferred with zsh-abbr
    initContent = ''
      # Abbreviations (deferred to run after zsh-abbr loads)
      _init_abbr() {
        # Modern CLI replacements (abbr for learning, see expansion)
        abbr -S -q find="fd"
        abbr -S -q top="btm"
        abbr -S -q htop="btm"
        abbr -S -q du="dust"
        abbr -S -q ps="procs"
        abbr -S -q sed="sd"

        # Convenience flags
        abbr -S -q curl="curl -fsSL"
        abbr -S -q df="df -h"
        abbr -S -q free="free -h"

        # Navigation
        abbr -S -q ..="cd .."
        abbr -S -q ...="cd ../.."
        abbr -S -q ....="cd ../../.."

        # Git (minimal - editor/Claude handles most operations)
        abbr -S -q G="git status"
        abbr -S -q gl="git l"
        abbr -S -q gp="git pull"
        abbr -S -q gP="git push"
        abbr -S -q 'gP!'="git please"
        abbr -S -q gw="git worktree"

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


        # Make abbreviations available in Tab completion (command position only)
        _complete_abbr() {
          # Only complete abbreviations for first word (command position)
          [[ $CURRENT -ne 1 ]] && return 1
          local -a _abbrs
          _abbrs=(''${(f)"$(abbr list-abbreviations 2>/dev/null | cut -d= -f1 | tr -d \")"})
          [[ ''${#_abbrs} -gt 0 ]] && compadd -V abbr -X 'abbreviations' -- "''${_abbrs[@]}"
          return 1
        }
        zstyle -g _completers ':completion:*' completer
        zstyle ':completion:*' completer _complete_abbr ''${_completers[@]}
      }

      # Defer abbr initialization (runs after zsh-abbr loads)
      zsh-defer _init_abbr
    '';
  };
}
