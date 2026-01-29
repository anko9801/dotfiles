_:

# Common SSH configuration for 1Password integration
# Platform-specific settings (identityAgent, gpg.ssh.program) are in platforms/*.nix
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # Global settings
      "*" = {
        forwardAgent = true;
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
}
