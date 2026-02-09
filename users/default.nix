# Default user configuration (used when user-specific config doesn't exist)
# Run ./setup to generate your own users/$USER.nix
{
  editor = "nvim";
  theme = "catppuccin";

  git = {
    name = "anko9801";
    email = "37263451+anko9801@users.noreply.github.com";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M";
  };

  sshHosts = { };
}
