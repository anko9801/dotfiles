{ lib, ... }:

{
  programs.zsh.initContent = lib.mkMerge [
    ''
      # Utility functions for common workflows

      mkcd() {
          mkdir -p "$1" && cd "$1" || return
      }

      # Extract various archive formats
      extract() {
          if [ -f "$1" ]; then
              case "$1" in
                  *.tar.bz2)   tar xjf "$1"   ;;
                  *.tar.gz)    tar xzf "$1"   ;;
                  *.bz2)       bunzip2 "$1"   ;;
                  *.rar)       unrar x "$1"   ;;
                  *.gz)        gunzip "$1"    ;;
                  *.tar)       tar xf "$1"    ;;
                  *.tbz2)      tar xjf "$1"   ;;
                  *.tgz)       tar xzf "$1"   ;;
                  *.zip)       unzip "$1"     ;;
                  *.Z)         uncompress "$1";;
                  *.7z)        7z x "$1"      ;;
                  *.xz)        xz -d "$1"     ;;
                  *.tar.xz)    tar xJf "$1"   ;;
                  *.zst)       zstd -d "$1"   ;;
                  *.tar.zst)   tar --zstd -xf "$1" ;;
                  *)           echo "'$1' cannot be extracted via extract()" ;;
              esac
          else
              echo "'$1' is not a valid file"
          fi
      }

      # fzf-powered cd
      fcd() {
          local dir
          dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --height=40% --layout=reverse --border --preview 'eza --tree --level=2 --color=always {} | head -100') && cd "$dir" || return
      }

      # Kill process with fzf
      fkill() {
          local pid
          pid=$(ps aux | sed 1d | fzf --height=40% --layout=reverse --border --multi | awk '{print $2}')
          if [[ -n "$pid" ]]; then
              echo "$pid" | xargs kill -9
          fi
      }

      # Git branch switch with fzf
      fbr() {
          local branches branch
          branches=$(git branch --all | grep -v HEAD) &&
          branch=$(echo "$branches" | fzf --height=40% --layout=reverse --border -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
          git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
      }

      # Docker container exec with fzf
      dexec() {
          local container
          container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | sed 1d | fzf --height=40% --layout=reverse --border | awk '{print $1}')
          if [[ -n "$container" ]]; then
              docker exec -it "$container" /bin/bash || docker exec -it "$container" /bin/sh
          fi
      }

      # Search history with fzf
      fh() {
          print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf --height=40% --layout=reverse --border --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
      }

      # Git log with fzf
      fgl() {
          git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' | awk '{print $1}'
      }

      # Startup time benchmarks (10-run average)
      zsh-startuptime() {
          local total=0
          for i in {1..10}; do
              local start=$(($(date +%s%N)/1000000))
              zsh -i -c exit
              local end=$(($(date +%s%N)/1000000))
              total=$((total + end - start))
          done
          echo "Average: $((total / 10))ms"
      }

      nvim-startuptime() {
          nvim --startuptime /tmp/nvim-startup.log -c 'quit'
          tail -1 /tmp/nvim-startup.log
      }

      # Update all package managers at once
      plugupdate() {
          echo "==> Updating Nix flake..."
          (cd ~/dotfiles && nix flake update)
          echo "==> Updating mise..."
          mise upgrade
          echo "==> Updating Neovim plugins..."
          nvim --headless '+Lazy sync' +qa
          echo "==> Done!"
      }

      # Cross-platform clipboard (pbcopy/pbpaste aliases)
      if [[ -z "$WAYLAND_DISPLAY" ]] && [[ -z "$DISPLAY" ]]; then
          # WSL or no display
          if command -v clip.exe &>/dev/null; then
              alias pbcopy='clip.exe'
              alias pbpaste='powershell.exe -c Get-Clipboard'
          fi
      elif [[ -n "$WAYLAND_DISPLAY" ]]; then
          alias pbcopy='wl-copy'
          alias pbpaste='wl-paste'
      else
          alias pbcopy='xclip -selection clipboard'
          alias pbpaste='xclip -selection clipboard -o'
      fi

      # Git worktree helpers
      command -v git-wt &>/dev/null && eval "$(git-wt --init zsh)"

      wt() {
          local selected
          selected=$(git worktree list | tail -n +2 | fzf --height=40% --layout=reverse --border | awk '{print $1}')
          [[ -n "$selected" ]] && cd "$selected"
      }

      # 1Password CLI plugins (auto-inject credentials for supported CLIs)
      if command -v op &>/dev/null; then
          command -v gh &>/dev/null && eval "$(op plugin init gh)"
          command -v aws &>/dev/null && eval "$(op plugin init aws)"
          command -v gcloud &>/dev/null && eval "$(op plugin init gcloud)"
          command -v az &>/dev/null && eval "$(op plugin init az)"
          command -v stripe &>/dev/null && eval "$(op plugin init stripe)"
      fi

      # Load API keys from 1Password into environment variables
      # Usage: load-secrets [vault]  (default: Personal)
      load-secrets() {
          if ! command -v op &>/dev/null; then
              echo "1Password CLI (op) not found"
              return 1
          fi

          # Check if signed in
          if ! op account list &>/dev/null; then
              echo "Signing in to 1Password..."
              eval $(op signin)
          fi

          local vault="''${1:-Personal}"

          # Load API keys (customize these paths to match your 1Password items)
          echo "Loading secrets from vault: $vault"

          # Example: export OPENAI_API_KEY=$(op read "op://$vault/OpenAI/api-key" 2>/dev/null)
          # Example: export ANTHROPIC_API_KEY=$(op read "op://$vault/Anthropic/api-key" 2>/dev/null)

          # Add your secrets here:
          [[ -n "$(op read "op://$vault/OpenAI/credential" 2>/dev/null)" ]] && \
              export OPENAI_API_KEY=$(op read "op://$vault/OpenAI/credential")
          [[ -n "$(op read "op://$vault/Anthropic/credential" 2>/dev/null)" ]] && \
              export ANTHROPIC_API_KEY=$(op read "op://$vault/Anthropic/credential")
          [[ -n "$(op read "op://$vault/GitHub Token/credential" 2>/dev/null)" ]] && \
              export GITHUB_TOKEN=$(op read "op://$vault/GitHub Token/credential")

          echo "Secrets loaded!"
      }

      # Quick secret read
      # Usage: opsecret "OpenAI/api-key"
      opsecret() {
          op read "op://Personal/$1" 2>/dev/null || op read "op://Private/$1" 2>/dev/null
      }
    ''
  ];
}
