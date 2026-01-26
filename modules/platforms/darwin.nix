{
  config,
  pkgs,
  lib,
  ...
}:

{
  # macOS-specific configuration
  home.homeDirectory = lib.mkDefault "/Users/anko";

  home.sessionVariables = {
    # 1Password SSH Agent (macOS path)
    SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  # macOS-specific packages
  home.packages = with pkgs; [
    # macOS utilities
    coreutils # GNU coreutils
    findutils # GNU find
    gnugrep # GNU grep
    gnutar # GNU tar

    # macOS-specific tools
    darwin.trash # Move to trash
    terminal-notifier # macOS notifications
  ];

  # SSH configuration for macOS (1Password agent)
  programs.ssh.extraConfig = ''
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  '';

  # Git SSH signing program for macOS (1Password)
  programs.git.settings = {
    gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    credential.helper = "osxkeychain";
  };

  # Homebrew integration (if using nix-darwin, this would be different)
  # For standalone Home Manager, we just add brew to PATH
  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  # macOS-specific zsh configuration
  programs.zsh.initContent = lib.mkAfter ''
    # ==============================================================================
    # macOS-Specific Configuration
    # ==============================================================================

    # Homebrew settings
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1

    # Use GNU tools instead of BSD
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
    export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

    # iTerm2 integration
    [[ -e "''${HOME}/.iterm2_shell_integration.zsh" ]] && source "''${HOME}/.iterm2_shell_integration.zsh"
  '';
}
