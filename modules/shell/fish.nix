{
  pkgs,
  ...
}:

{
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

        # PATH additions
        fish_add_path -g $HOME/.local/bin
        fish_add_path -g $HOME/go/bin
        fish_add_path -g $HOME/.cargo/bin
        fish_add_path -g $HOME/.rye/shims
        fish_add_path -g $HOME/.juliaup/bin
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
        ll = "eza -la";
        la = "eza -a";
        lt = "eza --tree";

        # Safety
        rm = "rm -i";
        cp = "cp -i";
        mv = "mv -i";
      };

      shellAliases = {
        # Modern replacements
        cat = "bat";
        ls = "eza";
        find = "fd";
        grep = "rg";
        top = "btm";
        du = "dust";
        df = "duf";
        ps = "procs";

        # Shortcuts
        v = "nvim";
        vim = "nvim";
        lg = "lazygit";
        y = "yazi";
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
            rev = "v1.4.2";
            hash = "sha256-4cnOGQR5cCCRVqKX+3B3ghPIG5O8kY8Ny8B+PwXBnBE=";
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
