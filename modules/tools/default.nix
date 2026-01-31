_:

{
  imports = [
    ../theme.nix
    ./cli.nix
    ./dev.nix
    ./linters.nix
    ./git.nix
    ./ssh.nix
    ./terminal.nix
    ./neovim
    ./vscode.nix
    ./security.nix
    ./extras.nix
    ./claude
  ];
}
