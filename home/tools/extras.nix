{
  pkgs,
  lib,
  ...
}:

{
  home.packages =
    with pkgs;
    [
      nmap
      ouch
      dasel
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      trashy
    ];
}
