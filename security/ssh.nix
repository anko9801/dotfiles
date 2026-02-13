{
  lib,
  config,
  allHosts,
  ...
}:

let
  inherit (config.platform) isDarwin isLinuxDesktop;
  inherit (config.programs) onePassword;

  currentUser = config.home.username;

  # Filter servers that:
  # 1. type = "server" with hostname
  # 2. current user is in users list (users must be explicitly specified)
  sshHosts = lib.filterAttrs (
    _: host:
    host.type or "" == "server"
    && host ? hostname
    && host ? users
    && builtins.elem currentUser host.users
  ) allHosts;
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
    # macOS/Linux: IdentityAgent pointing to 1Password socket
    extraConfig = lib.mkIf (isDarwin || isLinuxDesktop) ''
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
