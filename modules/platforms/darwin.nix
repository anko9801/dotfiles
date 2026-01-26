{
  pkgs,
  lib,
  ...
}:

{
  home = {
    username = lib.mkForce "anko";
    homeDirectory = lib.mkForce "/Users/anko";

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
    ssh.extraConfig = ''
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';

    git.settings = {
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      credential.helper = "osxkeychain";
    };

    zsh.initContent = lib.mkAfter ''
      # macOS-Specific Configuration

      export HOMEBREW_NO_ANALYTICS=1
      export HOMEBREW_NO_AUTO_UPDATE=1

      export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
      export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
      export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

      [[ -e "''${HOME}/.iterm2_shell_integration.zsh" ]] && source "''${HOME}/.iterm2_shell_integration.zsh"
    '';
  };
}
