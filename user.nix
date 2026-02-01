# User-specific configuration
# Regenerate with: ./setup --non-interactive --git-name NAME --git-email EMAIL
{
  # Preferences
  editor = "nvim"; # nvim, code, hx
  theme = "catppuccin"; # catppuccin, nord, gruvbox

  # Git configuration
  git = {
    name = "anko9801";
    email = "37263451+anko9801@users.noreply.github.com";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M";
  };

  # SSH hosts (servers, etc.)
  sshHosts = {
    pikachu = {
      hostname = "140.238.55.181";
      user = "ubuntu";
    };
    metamon = {
      hostname = "150.230.108.22";
      user = "ubuntu";
    };
    bracky = {
      hostname = "168.138.210.152";
      user = "ubuntu";
    };
    pochama = {
      hostname = "193.123.167.108";
      user = "ubuntu";
    };
  };
}
