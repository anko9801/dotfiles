# WSL configuration (WHM module)
# .wslconfig (global VM settings) + wsl.conf (per-distro settings)
_: {
  programs.wsl = {
    enable = true;

    # .wslconfig → %USERPROFILE%/.wslconfig
    settings = {
      memory = "8GB";
      swap = "4GB";
      localhostForwarding = true;
      nestedVirtualization = true;
      guiApplications = true;
      dnsTunneling = true;
      networkingMode = "mirrored";
      firewall = true;
      autoProxy = true;
    };
    experimental = {
      autoMemoryReclaim = "dropCache";
      sparseVhd = true;
    };

    # wsl.conf → staged at %USERPROFILE%/.config/wsl/wsl.conf
    # Deploy: sudo cp /mnt/c/Users/<user>/.config/wsl/wsl.conf /etc/wsl.conf
    conf = {
      boot.systemd = true;
      network = {
        generateHosts = true;
        generateResolvConf = true;
      };
      interop = {
        enabled = true;
        appendWindowsPath = true;
      };
      automount = {
        enabled = true;
        root = "/mnt/";
        options = "metadata,umask=22,fmask=11";
        mountFsTab = true;
      };
    };
  };
}
