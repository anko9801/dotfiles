{ pkgs, ... }:

{
  imports = [
    ../../home/tools
    ../../home/editor
  ];

  home = {
    sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    packages = with pkgs; [
      coreutils
      findutils
      gnugrep
      gnutar
      darwin.trash
      terminal-notifier
    ];
  };
}
