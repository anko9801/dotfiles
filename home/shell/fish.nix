{
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.peco ];

  programs = {
    fish = {
      enable = true;

      interactiveShellInit = ''
        # Disable greeting
        set -g fish_greeting

        # Vi mode
        fish_vi_key_bindings

        # Tool integrations (starship, fzf, zoxide handled by programs.*)
        mise activate fish | source
        uv generate-shell-completion fish | source
        git wt --init fish | source

        # PATH additions (paths in home.sessionPath are inherited automatically)
        fish_add_path -g $HOME/.rye/shims
        fish_add_path -g $HOME/.juliaup/bin

        # Cargo/Rust environment
        test -f $HOME/.cargo/env.fish && source $HOME/.cargo/env.fish
      '';

      shellAbbrs = {
        # Git
        g = "git";
        ga = "git add";
        gc = "git commit";
        gco = "git checkout";
        gd = "git diff";
        gl = "git log --oneline";
        gp = "git push";
        gpl = "git pull";
        gs = "git status";
        gsw = "git switch";

        # Directory
        ".." = "cd ..";
        "..." = "cd ../..";
      };

      shellAliases = {
        df = "duf";
      };

      plugins = [
        # z - directory jumper (like zoxide but fish-native)
        {
          name = "z";
          inherit (pkgs.fishPlugins.z) src;
        }
        # fzf integration
        {
          name = "fzf-fish";
          inherit (pkgs.fishPlugins.fzf-fish) src;
        }
        # bd - go back to directory
        {
          name = "fish-bd";
          src = pkgs.fetchFromGitHub {
            owner = "0rax";
            repo = "fish-bd";
            rev = "v1.3.3";
            hash = "sha256-GeWjoakXa0t2TsMC/wpLEmsSVGhHFhBVK3v9eyQdzv0=";
          };
        }
        # Done - notification when long command finishes
        {
          name = "done";
          inherit (pkgs.fishPlugins.done) src;
        }
      ];

      functions = {
        # Quick directory creation and cd
        mkcd = "mkdir -p $argv[1] && cd $argv[1]";

        # Git worktree helpers
        gwl = "git worktree list";
        gwa = "git worktree add $argv";
        gwr = "git worktree remove $argv";

        # Open in browser (WSL)
        open = ''
          if test -f /proc/sys/fs/binfmt_misc/WSLInterop
            wslview $argv
          else
            xdg-open $argv
          end
        '';

        # Peco history search (Ctrl+R alternative)
        peco_select_history = ''
          if test (count $argv) = 0
            set peco_flags --layout=bottom-up
          else
            set peco_flags --layout=bottom-up --query "$argv"
          end
          history | peco $peco_flags | read foo
          if test -n "$foo"
            commandline $foo
          else
            commandline ""
          end
        '';

        # Peco process kill
        peco_kill = ''
          ps ax -o pid,time,command | peco --query "$argv" | awk '{print $1}' | xargs kill
        '';
      };
    };

    # Enable fish integrations
    starship.enableFishIntegration = true;
    fzf.enableFishIntegration = true;
    zoxide.enableFishIntegration = true;
    direnv.enableFishIntegration = true;
    atuin.enableFishIntegration = true;
  };
}
