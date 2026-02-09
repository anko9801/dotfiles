{ ... }:

{
  imports = [
    ./ai.nix
    # ./debug.nix  # Excluded: heavy packages (vscode-js-debug, lldb) slow CI builds
    ./editing.nix
    ./git.nix
    ./navigation.nix
    ./terminal.nix
    ./treesitter.nix
    ./ui.nix
  ];

  programs.nixvim.plugins = {
    # lz-n: Lazy loading framework for nixvim
    lz-n.enable = true;
  };
}
