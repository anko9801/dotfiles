{
  config,
  pkgs,
  lib,
  ...
}:

# Common SSH configuration for 1Password integration
# Platform-specific settings (identityAgent, gpg.ssh.program) are in platforms/*.nix
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
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
}
