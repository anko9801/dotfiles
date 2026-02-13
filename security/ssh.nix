{
  lib,
  config,
  remoteServers,
  ...
}:

let
  p = config.platform;
  inherit (config.programs) onePassword;

  currentUser = config.home.username;

  # Filter remote servers where current user is in users list
  sshHosts = lib.filterAttrs (
    _: host: host ? hostname && host ? users && builtins.elem currentUser host.users
  ) remoteServers;
in
{
  # SSH_AUTH_SOCK points to 1Password agent socket
  home.sessionVariables = {
    # Replace ~ with $HOME for shell expansion
    SSH_AUTH_SOCK = builtins.replaceStrings [ "~" ] [ "$HOME" ] onePassword.agentSocket;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = lib.mkDefault false;

    # WSL: no IdentityAgent (agent forwarded via npiperelay)
    # macOS/Linux native: IdentityAgent pointing to 1Password socket
    extraConfig = lib.mkIf (p.os == "darwin" || (p.os == "linux" && p.environment == "native")) ''
      IdentityAgent "${onePassword.agentSocket}"
    '';

    matchBlocks = {
      "*" = {
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
    }
    // (lib.mapAttrs (_: host: {
      inherit (host) hostname;
      user = host.sshUser or "root";
      identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
    }) sshHosts);
  };

  # Git SSH signing configuration (uses 1Password sign program)
  programs.git.settings = {
    gpg.format = "ssh";
    gpg.ssh.program = onePassword.signProgram;
  };
}
