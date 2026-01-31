{
  config,
  pkgs,
  lib,
  unfree-pkgs,
  ...
}:

let
  unfreePkgs = unfree-pkgs "modules/tools/vscode.nix";
in
{
  # VSCode - Only enable on non-WSL/non-genericLinux platforms
  # WSL should use Windows VSCode with Remote-WSL extension
  programs.vscode = lib.mkIf (!(config.targets.genericLinux.enable or false)) {
    enable = true;
    package = unfreePkgs.vscode;
    profiles.default = {
      extensions =
        with unfreePkgs.vscode-extensions;
        [
          # Vim
          vscodevim.vim

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

          # Themes
          pkief.material-icon-theme

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

      userSettings = {
        "editor.fontSize" = 14;
        "editor.fontFamily" = "'JetBrains Mono', 'Fira Code', monospace";
        "editor.fontLigatures" = true;
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "vim.useSystemClipboard" = true;
        "vim.leader" = "<space>";
        "workbench.colorTheme" = "Ayu Mirage";
        "workbench.iconTheme" = "material-icon-theme";
        "telemetry.telemetryLevel" = "off";
      };

      keybindings = [
        {
          key = "ctrl+`";
          command = "workbench.action.terminal.toggleTerminal";
        }
      ];
    };
  };
}
