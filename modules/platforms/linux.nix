{
  config,
  pkgs,
  lib,
  ...
}:

{
  home = {
    homeDirectory = lib.mkDefault "/home/anko";

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
      IdentityAgent ~/.1password/agent.sock
    '';

    git.settings.gpg.ssh.program = "op-ssh-sign";

    zsh.initContent = lib.mkAfter ''
      # Linux-Specific Configuration

      [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
      [[ -d "/var/lib/flatpak/exports/bin" ]] && export PATH="/var/lib/flatpak/exports/bin:$PATH"
    '';
  };
}
