# Darwin-specific home-manager configuration
# Added via home-manager.sharedModules
{ pkgs, ... }:

{
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
