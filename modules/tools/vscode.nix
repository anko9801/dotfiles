{
  config,
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
        # Files
        "files.associations" = {
          "*.sql" = "sql";
          "*.vue" = "vue";
          "*.sage" = "python";
          "*.tsx" = "typescriptreact";
        };
        "files.autoGuessEncoding" = false;
        "files.trimFinalNewlines" = false;
        "files.trimTrailingWhitespace" = false;
        "files.eol" = "\n";
        "files.watcherExclude" = {
          "**/.git/objects/**" = true;
          "**/.git/subtree-cache/**" = true;
          "**/node_modules/**" = true;
          "**/env/**" = true;
          "**/venv/**" = true;
          "**/.svn/**" = true;
        };
        "files.exclude" = {
          "**/.git" = true;
          "**/.DS_Store" = true;
          "**/__pycache__" = true;
          "**/.pytest_cache" = true;
          "venv" = true;
          "*.sublime-*" = true;
          "env*" = true;
        };

        # Editor
        "editor.accessibilitySupport" = "off";
        "editor.suggestSelection" = "first";
        "editor.inlineSuggest.enabled" = true;
        "editor.inlayHints.enabled" = "off";
        "editor.guides.indentation" = false;
        "editor.wordWrap" = "on";
        "editor.wordWrapColumn" = 150;
        "editor.lineNumbers" = "relative";
        "editor.renderWhitespace" = "boundary";
        "editor.renderControlCharacters" = true;
        "editor.minimap.enabled" = false;
        "editor.minimap.showSlider" = "always";
        "editor.minimap.renderCharacters" = false;
        "editor.guides.bracketPairs" = false;
        "editor.bracketPairColorization.enabled" = true;
        "editor.insertSpaces" = true;
        "editor.tabSize" = 2;
        "editor.fontFamily" = "'Moralerspace Neon', 'JetBrains Mono', monospace";
        "editor.fontLigatures" = "'dlig', 'calt', 'liga'";
        "editor.formatOnSave" = true;
        "editor.linkedEditing" = true;
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
        "editor.unicodeHighlight.includeComments" = true;
        "editor.cursorBlinking" = "solid";
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.codeActionsOnSave" = {
          "quickfix.biome" = "explicit";
          "source.fixAll.eslint" = "explicit";
          "source.organizeImports.biome" = "explicit";
        };

        # Language-specific
        "[html][css][javascript][javascriptreact][typescript][typescriptreact][json][jsonc][yaml][astro]" =
          {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
        "[go]" = {
          "editor.defaultFormatter" = "golang.go";
        };
        "[python]" = {
          "editor.tabSize" = 4;
          "editor.formatOnType" = true;
        };
        "[rust]" = {
          "editor.tabSize" = 4;
          "editor.defaultFormatter" = "rust-lang.rust-analyzer";
        };
        "[cpp]" = {
          "editor.tabSize" = 2;
          "editor.detectIndentation" = false;
          "editor.wordBasedSuggestions" = "off";
          "editor.suggest.insertMode" = "replace";
          "editor.semanticHighlighting.enabled" = true;
        };
        "[markdown]" = {
          "editor.unicodeHighlight.ambiguousCharacters" = false;
          "editor.unicodeHighlight.invisibleCharacters" = false;
          "diffEditor.ignoreTrimWhitespace" = false;
          "editor.wordWrap" = "on";
          "editor.quickSuggestions" = {
            "comments" = "off";
            "strings" = "off";
            "other" = "off";
          };
          "editor.formatOnSave" = false;
        };
        "[vue]" = {
          "editor.tabSize" = 2;
        };
        "[haskell]" = {
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
        };
        "[tex][latex]" = {
          "editor.suggest.snippetsPreventQuickSuggestions" = false;
          "editor.wordBasedSuggestions" = "off";
          "editor.tabSize" = 2;
        };

        # Language servers
        "python.languageServer" = "Default";
        "python.analysis.typeCheckingMode" = "strict";
        "go.toolsManagement.autoUpdate" = true;
        "go.formatTool" = "gofmt";
        "rust-analyzer.showUnlinkedFileNotification" = false;
        "rust-analyzer.check.command" = "clippy";
        "eslint.useESLintClass" = true;
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "typescript.updateImportsOnFileMove.enabled" = "always";

        # Workbench
        "workbench.iconTheme" = "vscode-icons";
        "workbench.colorCustomizations" = {
          "editor.lineHighlightBackground" = "#1073cf2d";
          "editor.lineHighlightBorder" = "#9fced11f";
        };
        "workbench.editor.labelFormat" = "short";
        "workbench.editor.revealIfOpen" = true;
        "workbench.editor.showIcons" = false;
        "workbench.editor.highlightModifiedTabs" = true;
        "workbench.editor.tabSizing" = "shrink";
        "workbench.editor.tabCloseButton" = "off";
        "workbench.editor.tabActionCloseVisibility" = false;
        "workbench.startupEditor" = "none";
        "workbench.editor.openPositioning" = "first";
        "workbench.list.automaticKeyboardNavigation" = false;
        "workbench.editor.showTabs" = "multiple";
        "workbench.editor.enablePreview" = true;
        "workbench.editor.enablePreviewFromQuickOpen" = true;
        "workbench.tree.indent" = 20;
        "workbench.layoutControl.enabled" = false;
        "window.commandCenter" = false;

        # Explorer
        "explorer.openEditors.visible" = 0;

        # Search
        "search.exclude" = {
          "**/bower_components" = true;
          "**/vendor" = true;
          "**/env" = true;
          "**/venv" = true;
          "tags" = true;
          "**/.svn" = true;
          "**/.git" = true;
          "**/.DS_Store" = true;
          "**/node_modules" = true;
        };

        # Terminal
        "terminal.integrated.copyOnSelection" = true;
        "terminal.integrated.fontSize" = 15;
        "terminal.integrated.enableMultiLinePasteWarning" = "never";
        "terminal.integrated.tabs.enabled" = true;
        "terminal.integrated.tabs.hideCondition" = "never";
        "terminal.integrated.enablePersistentSessions" = false;

        # Git
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "git.openRepositoryInParentFolders" = "never";
        "gitlens.gitCommands.skipConfirmations" = [
          "fetch:command"
          "stash-push:command"
          "switch:command"
          "push:command"
        ];
        "githubPullRequests.pullBranch" = "never";

        # Vim
        "vim.useSystemClipboard" = false;
        "vim.hlsearch" = true;
        "vim.useCtrlKeys" = true;
        "vim.ignorecase" = true;
        "vim.incsearch" = true;
        "vim.sneak" = true;
        "vim.foldfix" = true;
        "vim.normalModeKeyBindingsNonRecursive" = [
          {
            "before" = [ "<Esc>" ];
            "commands" = [ ":nohl" ];
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
        "vim.insertModeKeyBindings" = [
          {
            "before" = [
              "j"
              "k"
            ];
            "after" = [ "<Esc>" ];
          }
        ];

        # Debug
        "debug.inlineValues" = "on";

        # Emmet
        "emmet.includeLanguages" = {
          "twig" = "html";
          "vue-html" = "html";
        };
        "emmet.variables" = {
          "lang" = "ja";
        };

        # CSS lint
        "css.lint.float" = "error";
        "css.lint.propertyIgnoredDueToDisplay" = "error";
        "css.lint.universalSelector" = "error";
        "css.lint.boxModel" = "error";
        "css.lint.duplicateProperties" = "error";
        "css.lint.idSelector" = "error";

        # Misc
        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;
        "security.workspace.trust.untrustedFiles" = "open";
        "diffEditor.wordWrap" = "on";
        "cSpell.diagnosticLevel" = "Hint";

        # Accessibility (disable sounds)
        "accessibility.signals.lineHasError" = {
          "sound" = "off";
          "announcement" = "auto";
        };
        "accessibility.signals.lineHasWarning" = {
          "sound" = "off";
          "announcement" = "auto";
        };
        "accessibility.signals.progress" = {
          "sound" = "off";
          "announcement" = "auto";
        };
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
