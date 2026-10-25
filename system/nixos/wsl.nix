{
  inputs,
  username,
  ...
}:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
    interop = {
      register = true;
      includePath = false;
    };
  };

  networking = {
    hostName = "nixos-wsl";
    # WSL generates resolv.conf; NixOS must not manage the same file.
    resolvconf.enable = false;
  };
}
