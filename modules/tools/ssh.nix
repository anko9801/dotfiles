{ lib, ... }:

{
  # Platform-specific options for 1Password SSH integration
  options.tools.ssh = {
    onePasswordAgentPath = lib.mkOption {
      type = lib.types.str;
      default = "~/.1password/agent.sock";
      description = "Path to 1Password SSH agent socket";
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

        # Oracle Cloud servers
        "pikachu" = {
          hostname = "140.238.55.181";
          user = "ubuntu";
          identityFile = "~/.ssh/id_ed25519";
        };
        "metamon" = {
          hostname = "150.230.108.22";
          user = "ubuntu";
          identityFile = "~/.ssh/id_ed25519";
        };
        "bracky" = {
          hostname = "168.138.210.152";
          user = "ubuntu";
          identityFile = "~/.ssh/id_ed25519";
        };
        "pochama" = {
          hostname = "193.123.167.108";
          user = "ubuntu";
          identityFile = "~/.ssh/id_ed25519";
        };
      };
    };

    # Git SSH signing configuration (uses platform-specific program)
    programs.git.settings.gpg.format = "ssh";
  };
}
