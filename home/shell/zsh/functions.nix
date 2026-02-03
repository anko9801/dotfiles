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

      # OSC 52 clipboard (works everywhere: SSH, tmux, zellij, etc.)
      pbcopy() {
          local input
          if [[ -p /dev/stdin ]]; then
              input=$(cat)
          else
              input="$*"
          fi
          # OSC 52: \e]52;c;BASE64\a
          printf '\e]52;c;%s\a' "$(printf '%s' "$input" | base64 | tr -d '\n')"
      }

      # pbpaste: defined in os-specific configs (wsl.nix, darwin.nix, etc.)
      # Git worktree helpers (deferred)
      _init_git_wt() {
          command -v git-wt &>/dev/null && eval "$(git-wt --init zsh)"
      }
      zsh-defer _init_git_wt

      wt() {
          local selected
          selected=$(git worktree list | tail -n +2 | fzf --height=40% --layout=reverse --border | awk '{print $1}')
          [[ -n "$selected" ]] && cd "$selected"
      }

      # Lazy load mise and 1Password (deferred for faster startup)
      _init_lazy_loaders() {
          # mise lazy loading
          if command -v mise &>/dev/null; then
              _mise_lazy_load() {
                  unfunction node npm npx pnpm python python3 pip ruby gem go deno bun lua java mise 2>/dev/null
                  eval "$(mise activate zsh)"
              }
              for cmd in node npm npx pnpm python python3 pip ruby gem go deno bun lua java mise; do
                  eval "$cmd() { _mise_lazy_load; $cmd \"\$@\" }"
              done
          fi

          # 1Password CLI plugins lazy loading
          if command -v op &>/dev/null; then
              _op_plugin_lazy() {
                  local cmd=$1; shift
                  unfunction $cmd 2>/dev/null
                  eval "$(op plugin init $cmd)"
                  $cmd "$@"
              }
              command -v gh &>/dev/null && gh() { _op_plugin_lazy gh "$@" }
              command -v aws &>/dev/null && aws() { _op_plugin_lazy aws "$@" }
              command -v gcloud &>/dev/null && gcloud() { _op_plugin_lazy gcloud "$@" }
              command -v az &>/dev/null && az() { _op_plugin_lazy az "$@" }
              command -v stripe &>/dev/null && stripe() { _op_plugin_lazy stripe "$@" }
          fi
      }
      zsh-defer _init_lazy_loaders

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

      # === Server Deployment (nixos-anywhere) ===

      # Deploy NixOS to a remote server
      # Usage: nixos-deploy root@192.168.1.100 example-vps
      nixos-deploy() {
          if [[ $# -lt 2 ]]; then
              echo "Usage: nixos-deploy <user@host> <config-name>"
              echo ""
              echo "Available configs:"
              nix flake show ~/dotfiles 2>/dev/null | grep -A100 "nixosConfigurations" | grep "│" | head -20
              return 1
          fi
          local target="$1"
          local config="$2"
          echo "Deploying $config to $target..."
          nix run github:nix-community/nixos-anywhere -- --flake "$HOME/dotfiles#$config" "$target"
      }

      # Update a deployed NixOS server
      # Usage: nixos-update root@192.168.1.100 example-vps
      nixos-update() {
          if [[ $# -lt 2 ]]; then
              echo "Usage: nixos-update <user@host> <config-name>"
              return 1
          fi
          local target="$1"
          local config="$2"
          echo "Updating $config on $target..."
          NIX_SSHOPTS="-o StrictHostKeyChecking=no" \
            nixos-rebuild switch --flake "$HOME/dotfiles#$config" \
            --target-host "$target" --use-remote-sudo
      }

      # Create new server config from template
      # Usage: nixos-new-server my-server
      nixos-new-server() {
          if [[ -z "$1" ]]; then
              echo "Usage: nixos-new-server <server-name>"
              return 1
          fi
          local name="$1"
          local dest="$HOME/dotfiles/system/servers/$name"
          if [[ -d "$dest" ]]; then
              echo "Server config '$name' already exists"
              return 1
          fi
          cp -r "$HOME/dotfiles/system/servers/example-vps" "$dest"
          sed -i "s/example-vps/$name/g" "$dest/default.nix"
          echo "Created server config at: $dest"
          echo ""
          echo "Next steps:"
          echo "  1. Edit $dest/default.nix (add SSH keys, hostname)"
          echo "  2. Edit $dest/disko.nix (set correct disk device)"
          echo "  3. Add to flake.nix nixosConfigurations"
          echo "  4. Deploy: nixos-deploy root@<ip> $name"
      }
    ''
  ];
}
