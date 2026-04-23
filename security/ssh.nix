{
  lib,
  config,
  remoteServers,
  ...
}:

let
  p = config.platform;
  inherit (config.defaults) ssh;

  currentUser = config.home.username;

  # Filter remote servers where current user is in users list
  sshHosts = lib.filterAttrs (
    _: host: host ? hostname && host ? users && builtins.elem currentUser host.users
  ) remoteServers;
in
{
  # SSH_AUTH_SOCK (if a credential provider set agentSocket)
  home.sessionVariables = lib.mkIf (ssh.agentSocket != null) {
    SSH_AUTH_SOCK = builtins.replaceStrings [ "~" ] [ "$HOME" ] ssh.agentSocket;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = lib.mkDefault false;

    # macOS/Linux native: IdentityAgent pointing to agent socket
    extraConfig =
      lib.mkIf
        (ssh.agentSocket != null && (p.os == "darwin" || (p.os == "linux" && p.environment == "native")))
        ''
          IdentityAgent "${ssh.agentSocket}"
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
      tsubame = {
        hostname = "login.t4.gsic.titech.ac.jp";
        user = "uk07267";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    }
    // (lib.mapAttrs (_: host: {
      inherit (host) hostname;
      user = host.sshUser or "root";
      identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
    }) sshHosts);
  };

  # Git SSH signing (if a credential provider set signProgram)
  programs.git.settings = lib.mkIf (ssh.signProgram != null) {
    gpg.format = "ssh";
    gpg.ssh.program = ssh.signProgram;
  };
}
