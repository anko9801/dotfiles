# User and host definitions — edit this file to personalize your setup
{
  users = {
    # Replace with your own info
    default = {
      editor = "vim";
      git = {
        name = "Your Name";
        email = "you@example.com";
      };
    };
  };

  hosts = {
    linux-wsl = {
      system = "x86_64-linux";
      user = "default";
      modules = [
        ./shell/defaults.nix
        ./shell/bash.nix
        ./shell/zsh.nix
        ./editor/vim.nix
        ./tools/git.nix
      ];
    };
    linux-desktop = {
      system = "x86_64-linux";
      user = "default";
      modules = [
        ./shell/defaults.nix
        ./shell/bash.nix
        ./shell/zsh.nix
        ./editor/vim.nix
        ./tools/git.nix
      ];
    };
  };

  # Default host for each environment (used by `nix run .#switch`)
  defaultHosts = {
    wsl = "linux-wsl";
    linux = "linux-desktop";
  };

  versions = {
    home = "24.11";
  };
}
