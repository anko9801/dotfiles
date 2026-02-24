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

  networking.hostName = "nixos-wsl";
}
