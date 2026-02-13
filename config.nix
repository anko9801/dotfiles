# Fleet configuration: users, hosts, and modules
{
  # Base modules loaded for all configurations
  commonModules = [
    ./system/home-manager/core.nix
    ./system/defaults.nix
    # Dev
    ./dev/build-tools.nix
    ./dev/go.nix
    ./dev/mise.nix
    ./dev/nix.nix
    ./dev/node.nix
    ./dev/python.nix
    ./dev/rust.nix
    # Security
    ./security/1password.nix
    ./security/gitleaks.nix
    ./security/gpg.nix
    ./security/ssh.nix
    # Shell
    ./shell/aliases.nix
    ./shell/atuin.nix
    ./shell/bash.nix
    ./shell/defaults.nix
    ./shell/eza.nix
    ./shell/fish.nix
    ./shell/fzf.nix
    ./shell/readline.nix
    ./shell/starship.nix
    ./shell/zoxide.nix
    ./shell/zsh
    # Theme
    ./theme/catppuccin-mocha.nix
    ./theme/default.nix
  ];

  users = {
    anko = {
      editor = "nvim";
      theme = "catppuccin";
      git = {
        name = "anko9801";
        email = "37263451+anko9801@users.noreply.github.com";
        sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M";
      };
    };
  };

  hosts = {
    # Workstations
    wsl = {
      platform = "wsl";
      type = "workstation";
      modules = [
        ./ai
        ./tools
        ./editor
        ./terminal
        ./terminal/zellij
      ];
    };
    desktop = {
      platform = "linux";
      type = "workstation";
      modules = [
        ./ai
        ./tools
        ./editor
        ./terminal
        ./desktop
      ];
    };
    windows = {
      platform = "windows";
      type = "workstation";
      modules = [ ];
    };
    server = {
      platform = "linux";
      type = "server";
      modules = [
        ./editor/vim.nix
        ./tools/git
        ./tools/cli.nix
        ./tools/bat.nix
        ./terminal/tmux.nix
      ];
    };
    mac = {
      platform = "darwin";
      type = "workstation";
      modules = [
        ./ai
        ./tools
        ./editor
        ./terminal
      ];
    };

    # Servers (users = SSH access)
    pikachu = {
      platform = "nixos";
      type = "server";
      hostname = "140.238.55.181";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
    metamon = {
      platform = "nixos";
      type = "server";
      hostname = "150.230.108.22";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
    bracky = {
      platform = "nixos";
      type = "server";
      hostname = "168.138.210.152";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
    pochama = {
      platform = "nixos";
      type = "server";
      hostname = "193.123.167.108";
      sshUser = "ubuntu";
      users = [ "anko" ];
    };
  };
}
