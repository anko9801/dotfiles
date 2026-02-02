# Default user configuration (used when user-specific config doesn't exist)
# Run ./setup to generate your own users/$USER.nix
{
  editor = "nvim";
  theme = "catppuccin";

  git = {
    name = "nixuser";
    email = "nixuser@example.com";
    sshKey = "";
  };

  sshHosts = { };
}
