{
  pkgs,
  config,
  lib,
  ...
}:

{
  # 1Password paths for macOS
  tools.ssh = {
    onePasswordAgentPath = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    onePasswordSignProgram = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  };

  home = {
    sessionVariables.SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";

    sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    packages = with pkgs; [
      coreutils
      findutils
      gnugrep
      gnutar
      darwin.trash
      terminal-notifier
    ];
  };

  programs = {
    # yazi: heavy (~1GB due to ffmpeg) but useful with Ghostty image preview
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings.manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
      };
    };

    ssh.extraConfig = ''
      IdentityAgent "${config.tools.ssh.onePasswordAgentPath}"
    '';

    git.settings = {
      gpg.ssh.program = config.tools.ssh.onePasswordSignProgram;
      credential.helper = "osxkeychain";
    };

    zsh.initContent = lib.mkAfter ''
      # macOS-Specific Configuration
      export HOMEBREW_NO_ANALYTICS=1
      export HOMEBREW_NO_AUTO_UPDATE=1

      # GNU tools from Homebrew
      export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
      export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
      export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

      # iTerm2 integration
      [[ -e "''${HOME}/.iterm2_shell_integration.zsh" ]] && source "''${HOME}/.iterm2_shell_integration.zsh"
    '';
  };
}
