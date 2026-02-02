{
  config,
  lib,
  unfreePkgs,
  ...
}:

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

      userSettings = {
        # ─────────────────────────────────────────────────────────────
        # Editor
        # ─────────────────────────────────────────────────────────────
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
        "editor.linkedEditing" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.codeActionsOnSave" = {
          "source.fixAll.eslint" = "explicit";
        };
        "editor.inlayHints.enabled" = "off";
        "editor.wordWrap" = "on";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.stickyScroll.enabled" = true;
        "editor.foldingImportsByDefault" = true;
        "editor.showFoldingControls" = "always";
        "editor.fontFamily" = "'Moralerspace Neon', 'JetBrains Mono', monospace";
        "editor.fontLigatures" = "'dlig', 'calt', 'liga'";
        "editor.lineNumbers" = "relative";
        "editor.cursorBlinking" = "solid";
        "editor.minimap.enabled" = false;
        "editor.renderWhitespace" = "boundary";
        "editor.renderControlCharacters" = true;
        "editor.rulers" = [
          {
            "column" = 80;
            "color" = "#00FF0010";
          }
          {
            "column" = 100;
            "color" = "#BDB76B15";
          }
          {
            "column" = 120;
            "color" = "#FA807219";
          }
        ];

        # ─────────────────────────────────────────────────────────────
        # Files
        # ─────────────────────────────────────────────────────────────
        "files.eol" = "\n";
        "files.insertFinalNewline" = true;
        "files.associations"."*.sage" = "python";
        "files.exclude" = {
          "**/__pycache__" = true;
          "**/.pytest_cache" = true;
        };

        # ─────────────────────────────────────────────────────────────
        # Language-specific
        # ─────────────────────────────────────────────────────────────
        "[python]" = {
          "editor.tabSize" = 4;
          "editor.formatOnType" = true;
        };
        "[rust]" = {
          "editor.tabSize" = 4;
          "editor.defaultFormatter" = "rust-lang.rust-analyzer";
        };
        "[go]"."editor.defaultFormatter" = "golang.go";
        "[cpp]" = {
          "editor.detectIndentation" = false;
          "editor.wordBasedSuggestions" = "off";
          "editor.suggest.insertMode" = "replace";
        };
        "[markdown]" = {
          "editor.formatOnSave" = false;
          "editor.unicodeHighlight.ambiguousCharacters" = false;
          "editor.unicodeHighlight.invisibleCharacters" = false;
          "editor.quickSuggestions" = {
            "comments" = "off";
            "strings" = "off";
            "other" = "off";
          };
        };

        # ─────────────────────────────────────────────────────────────
        # Extensions
        # ─────────────────────────────────────────────────────────────
        "python.analysis.typeCheckingMode" = "strict";
        "rust-analyzer.check.command" = "clippy";
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "typescript.updateImportsOnFileMove.enabled" = "always";
        "emmet.variables"."lang" = "ja";
        "cSpell.diagnosticLevel" = "Hint";

        # ─────────────────────────────────────────────────────────────
        # Workbench
        # ─────────────────────────────────────────────────────────────
        "workbench.startupEditor" = "none";
        "workbench.iconTheme" = "vscode-icons";
        "workbench.layoutControl.enabled" = false;
        "workbench.tree.indent" = 20;
        "workbench.tree.expandMode" = "singleClick";
        "workbench.list.smoothScrolling" = true;
        "workbench.colorCustomizations" = {
          "editor.lineHighlightBackground" = "#1073cf2d";
          "editor.lineHighlightBorder" = "#9fced11f";
        };
        # Tabs
        "workbench.editor.showIcons" = false;
        "workbench.editor.tabSizing" = "shrink";
        "workbench.editor.tabCloseButton" = "off";
        "workbench.editor.highlightModifiedTabs" = true;
        "workbench.editor.labelFormat" = "short";
        "workbench.editor.openPositioning" = "first";
        "workbench.editor.revealIfOpen" = true;
        "workbench.editor.limit.enabled" = true;
        "workbench.editor.limit.value" = 8;
        # Explorer
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.openEditors.visible" = 0;
        "explorer.fileNesting.enabled" = true;
        "explorer.fileNesting.patterns" = {
          "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb";
          "tsconfig.json" = "tsconfig.*.json";
          ".env" = ".env.*";
        };
        # Window
        "window.commandCenter" = false;

        # ─────────────────────────────────────────────────────────────
        # Terminal
        # ─────────────────────────────────────────────────────────────
        "terminal.integrated.fontSize" = 15;
        "terminal.integrated.copyOnSelection" = true;
        "terminal.integrated.tabs.hideCondition" = "never";
        "terminal.integrated.enableMultiLinePasteWarning" = "never";
        "terminal.integrated.enablePersistentSessions" = false;

        # ─────────────────────────────────────────────────────────────
        # Git
        # ─────────────────────────────────────────────────────────────
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.openRepositoryInParentFolders" = "never";
        "gitlens.gitCommands.skipConfirmations" = [
          "fetch:command"
          "stash-push:command"
          "switch:command"
          "push:command"
        ];
        "diffEditor.ignoreTrimWhitespace" = false;

        # ─────────────────────────────────────────────────────────────
        # Vim
        # ─────────────────────────────────────────────────────────────
        "vim.hlsearch" = true;
        "vim.incsearch" = true;
        "vim.ignorecase" = true;
        "vim.sneak" = true;
        "vim.foldfix" = true;
        "vim.useCtrlKeys" = true;
        "vim.useSystemClipboard" = false;
        "vim.normalModeKeyBindingsNonRecursive" = [
          {
            "before" = [ "<Esc>" ];
            "commands" = [ ":nohl" ];
          }
        ];
        "vim.normalModeKeyBindings" = [
          {
            "before" = [ "j" ];
            "after" = [
              "g"
              "j"
            ];
          }
          {
            "before" = [ "k" ];
            "after" = [
              "g"
              "k"
            ];
          }
        ];
        "vim.visualModeKeyBindings" = [
          {
            "before" = [ "<C-c>" ];
            "after" = [
              "\""
              "+"
              "y"
            ];
          }
          {
            "before" = [ "<C-v>" ];
            "after" = [
              "\""
              "+"
              "p"
            ];
          }
        ];
        "vim.insertModeKeyBindings" = [
          {
            "before" = [
              "j"
              "k"
            ];
            "after" = [ "<Esc>" ];
          }
        ];

        # ─────────────────────────────────────────────────────────────
        # Privacy
        # ─────────────────────────────────────────────────────────────
        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;
        "security.workspace.trust.untrustedFiles" = "open";
        "editor.accessibilitySupport" = "off";
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
