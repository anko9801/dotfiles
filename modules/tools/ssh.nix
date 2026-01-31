{ lib, userConfig, ... }:

{
  # Platform-specific options for 1Password SSH integration
  options.tools.ssh = {
    onePasswordAgentPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "~/.1password/agent.sock";
      description = "Path to 1Password SSH agent socket (null to disable)";
    };

    onePasswordSignProgram = lib.mkOption {
      type = lib.types.str;
      default = "op-ssh-sign";
      description = "Path to 1Password SSH signing program";
    };
  };

  config = {
    programs.ssh = {
      enable = true;
      # Disable default config, we set everything explicitly
      enableDefaultConfig = lib.mkDefault false;

      matchBlocks = {
        # Global settings
        "*" = {
          addKeysToAgent = "yes";
        };

        # Git hosting services
        "github.com" = {
          hostname = "github.com";
          user = "git";
        };
        "gitlab.com" = {
          hostname = "gitlab.com";
          user = "git";
        };

      }
      // (lib.mapAttrs (name: host: {
        hostname = host.hostname;
        user = host.user;
        identityFile = "~/.ssh/id_ed25519";
      }) userConfig.sshHosts);
    };

    # Git SSH signing configuration (uses platform-specific program)
    programs.git.settings.gpg.format = "ssh";
  };
}
