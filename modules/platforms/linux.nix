{
  pkgs,
  config,
  lib,
  ...
}:

{
  # 1Password paths for Linux
  tools.ssh = {
    onePasswordAgentPath = "~/.1password/agent.sock";
    onePasswordSignProgram = "op-ssh-sign";
  };

  home = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    };

    packages = with pkgs; [
      xdg-utils
      xclip
      wl-clipboard
    ];
  };

  programs = {
    ssh.extraConfig = ''
      IdentityAgent ${config.tools.ssh.onePasswordAgentPath}
    '';

    git.settings.gpg.ssh.program = config.tools.ssh.onePasswordSignProgram;

    zsh.initContent = lib.mkAfter ''
      # Linux-Specific Configuration
      [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
      [[ -d "/var/lib/flatpak/exports/bin" ]] && export PATH="/var/lib/flatpak/exports/bin:$PATH"
    '';
  };
}
