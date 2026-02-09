{
  config,
  lib,
  unfreePkgs,
  ...
}:

{
  imports = [ ./keybindings.nix ];

  # VSCode - Only enable on non-WSL/non-genericLinux platforms
  # WSL should use Windows VSCode with Remote-WSL extension
  programs.vscode = lib.mkIf (!(config.targets.genericLinux.enable or false)) {
    enable = true;
    package = unfreePkgs.vscode;
    profiles.default = {
      # Use external JSON file for settings
      userSettings = builtins.fromJSON (builtins.readFile ./settings.json);

      extensions =
        with unfreePkgs.vscode-extensions;
        [
          # Neovim integration (uses actual Neovim instance)
          asvetliakov.vscode-neovim

          # Languages
          ms-python.python
          ms-python.vscode-pylance
          rust-lang.rust-analyzer
          golang.go

          # Web
          dbaeumer.vscode-eslint
          esbenp.prettier-vscode
          bradlc.vscode-tailwindcss

          # Git
          eamodio.gitlens
          github.vscode-pull-request-github

          # Utilities
          editorconfig.editorconfig
          streetsidesoftware.code-spell-checker
          usernamehw.errorlens
          christian-kohler.path-intellisense

          # Theme
          vscode-icons-team.vscode-icons

          # Remote
          ms-vscode-remote.remote-ssh
        ]
        ++ unfreePkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "ayu";
            publisher = "teabyii";
            version = "1.0.5";
            sha256 = "sha256-+IFqgWliKr+qjBLmQlzF44XNbN7Br5a119v9WAnZOu4=";
          }
        ];
    };
  };
}
