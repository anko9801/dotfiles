{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Linux-specific configuration
  home.homeDirectory = lib.mkForce "/home/anko";

  home.sessionVariables = {
    # Wayland/X11 support
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";

    # 1Password SSH Agent (Linux path)
    SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
  };

  # Linux-specific packages
  home.packages = with pkgs; [
    xdg-utils # xdg-open, etc.
    xclip # X clipboard
    wl-clipboard # Wayland clipboard
  ];

  # SSH configuration for Linux
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      # 1Password SSH Agent for Linux
      IdentityAgent ~/.1password/agent.sock
    '';
    matchBlocks = {
      "*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
      };
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
      };
    };
  };

  # Git SSH signing program for Linux (1Password)
  programs.git.settings = {
    gpg.ssh.program = "op-ssh-sign";
  };

  # Linux-specific zsh configuration
  programs.zsh.initContent = lib.mkAfter ''
    # ==============================================================================
    # Linux-Specific Configuration
    # ==============================================================================

    # Snap/Flatpak support
    [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
    [[ -d "/var/lib/flatpak/exports/bin" ]] && export PATH="/var/lib/flatpak/exports/bin:$PATH"
  '';
}
