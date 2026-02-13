# Fleet configuration: users and hosts
{
  users = {
    anko = {
      editor = "nvim";
      theme = "catppuccin";
      git = {
        name = "anko9801";
        email = "37263451+anko9801@users.noreply.github.com";
        sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M";
      };
      modules = [
        ./ai
        ./tools
        ./editor
        ./terminal
      ];
    };
  };

  hosts = {
    # Workstations
    wsl = {
      platform = "wsl";
      type = "workstation";
      modules = [ ./terminal/zellij ];
    };
    desktop = {
      platform = "linux";
      type = "workstation";
      modules = [ ./desktop ];
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
      modules = [ ];
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
