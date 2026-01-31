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
        # ─────────────────────────────────────────────────────────────
        # Editor: Core behavior
        # ─────────────────────────────────────────────────────────────
        "editor.tabSize" = 2;
        "editor.insertSpaces" = true;
        "editor.formatOnSave" = true;
        "editor.linkedEditing" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.codeActionsOnSave" = {
          "quickfix.biome" = "explicit";
          "source.fixAll.eslint" = "explicit";
          "source.organizeImports.biome" = "explicit";
        };
        "editor.suggestSelection" = "first";
        "editor.inlineSuggest.enabled" = true;
        "editor.inlayHints.enabled" = "off";
        "editor.wordWrap" = "on";
        "editor.wordWrapColumn" = 150;

        # ─────────────────────────────────────────────────────────────
        # Editor: Display
        # ─────────────────────────────────────────────────────────────
        "editor.fontFamily" = "'Moralerspace Neon', 'JetBrains Mono', monospace";
        "editor.fontLigatures" = "'dlig', 'calt', 'liga'";
        "editor.lineNumbers" = "relative";
        "editor.cursorBlinking" = "solid";
        "editor.minimap.enabled" = false;
        "editor.renderWhitespace" = "boundary";
        "editor.renderControlCharacters" = true;
        "editor.unicodeHighlight.includeComments" = true;
        "editor.guides.indentation" = false;
        "editor.guides.bracketPairs" = false;
        "editor.bracketPairColorization.enabled" = true;
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
        "files.autoGuessEncoding" = false;
        "files.trimFinalNewlines" = false;
        "files.trimTrailingWhitespace" = false;
        "files.associations" = {
          "*.sql" = "sql";
          "*.vue" = "vue";
          "*.sage" = "python";
          "*.tsx" = "typescriptreact";
        };
        "files.exclude" = {
          "**/.git" = true;
          "**/.DS_Store" = true;
          "**/__pycache__" = true;
          "**/.pytest_cache" = true;
          "*.sublime-*" = true;
          "env*" = true;
          "venv" = true;
        };
        "files.watcherExclude" = {
          "**/.git/objects/**" = true;
          "**/.git/subtree-cache/**" = true;
          "**/.svn/**" = true;
          "**/node_modules/**" = true;
          "**/env/**" = true;
          "**/venv/**" = true;
        };

        # ─────────────────────────────────────────────────────────────
        # Language-specific overrides
        # ─────────────────────────────────────────────────────────────
        "[html][css][javascript][javascriptreact][typescript][typescriptreact][json][jsonc][yaml][astro]" =
          {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
        "[python]" = {
          "editor.tabSize" = 4;
          "editor.formatOnType" = true;
        };
        "[rust]" = {
          "editor.tabSize" = 4;
          "editor.defaultFormatter" = "rust-lang.rust-analyzer";
        };
        "[go]" = {
          "editor.defaultFormatter" = "golang.go";
        };
        "[cpp]" = {
          "editor.tabSize" = 2;
          "editor.detectIndentation" = false;
          "editor.wordBasedSuggestions" = "off";
          "editor.suggest.insertMode" = "replace";
          "editor.semanticHighlighting.enabled" = true;
        };
        "[markdown]" = {
          "editor.wordWrap" = "on";
          "editor.formatOnSave" = false;
          "editor.unicodeHighlight.ambiguousCharacters" = false;
          "editor.unicodeHighlight.invisibleCharacters" = false;
          "editor.quickSuggestions" = {
            "comments" = "off";
            "strings" = "off";
            "other" = "off";
          };
          "diffEditor.ignoreTrimWhitespace" = false;
        };
        "[vue]" = {
          "editor.tabSize" = 2;
        };
        "[haskell]" = {
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
        };
        "[tex][latex]" = {
          "editor.tabSize" = 2;
          "editor.wordBasedSuggestions" = "off";
          "editor.suggest.snippetsPreventQuickSuggestions" = false;
        };

        # ─────────────────────────────────────────────────────────────
        # Language servers & Extensions
        # ─────────────────────────────────────────────────────────────
        # Python
        "python.languageServer" = "Default";
        "python.analysis.typeCheckingMode" = "strict";
        # Rust
        "rust-analyzer.check.command" = "clippy";
        "rust-analyzer.showUnlinkedFileNotification" = false;
        # Go
        "go.formatTool" = "gofmt";
        "go.toolsManagement.autoUpdate" = true;
        # JavaScript/TypeScript
        "eslint.useESLintClass" = true;
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "typescript.updateImportsOnFileMove.enabled" = "always";
        # CSS
        "css.lint.boxModel" = "error";
        "css.lint.duplicateProperties" = "error";
        "css.lint.float" = "error";
        "css.lint.idSelector" = "error";
        "css.lint.propertyIgnoredDueToDisplay" = "error";
        "css.lint.universalSelector" = "error";
        # Emmet
        "emmet.includeLanguages" = {
          "twig" = "html";
          "vue-html" = "html";
        };
        "emmet.variables" = {
          "lang" = "ja";
        };
        # Spell checker
        "cSpell.diagnosticLevel" = "Hint";

        # ─────────────────────────────────────────────────────────────
        # Workbench & UI
        # ─────────────────────────────────────────────────────────────
        "workbench.startupEditor" = "none";
        "workbench.iconTheme" = "vscode-icons";
        "workbench.layoutControl.enabled" = false;
        "workbench.tree.indent" = 20;
        "workbench.list.automaticKeyboardNavigation" = false;
        "workbench.colorCustomizations" = {
          "editor.lineHighlightBackground" = "#1073cf2d";
          "editor.lineHighlightBorder" = "#9fced11f";
        };
        # Tabs
        "workbench.editor.showTabs" = "multiple";
        "workbench.editor.showIcons" = false;
        "workbench.editor.tabSizing" = "shrink";
        "workbench.editor.tabCloseButton" = "off";
        "workbench.editor.tabActionCloseVisibility" = false;
        "workbench.editor.highlightModifiedTabs" = true;
        "workbench.editor.labelFormat" = "short";
        "workbench.editor.openPositioning" = "first";
        "workbench.editor.revealIfOpen" = true;
        "workbench.editor.enablePreview" = true;
        "workbench.editor.enablePreviewFromQuickOpen" = true;
        # Window
        "window.commandCenter" = false;
        # Explorer
        "explorer.openEditors.visible" = 0;
        # Search
        "search.exclude" = {
          "**/.git" = true;
          "**/.svn" = true;
          "**/.DS_Store" = true;
          "**/node_modules" = true;
          "**/bower_components" = true;
          "**/vendor" = true;
          "**/env" = true;
          "**/venv" = true;
          "tags" = true;
        };

        # ─────────────────────────────────────────────────────────────
        # Terminal
        # ─────────────────────────────────────────────────────────────
        "terminal.integrated.fontSize" = 15;
        "terminal.integrated.copyOnSelection" = true;
        "terminal.integrated.tabs.enabled" = true;
        "terminal.integrated.tabs.hideCondition" = "never";
        "terminal.integrated.enableMultiLinePasteWarning" = "never";
        "terminal.integrated.enablePersistentSessions" = false;

        # ─────────────────────────────────────────────────────────────
        # Git
        # ─────────────────────────────────────────────────────────────
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
        "diffEditor.wordWrap" = "on";

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
        # Debug
        # ─────────────────────────────────────────────────────────────
        "debug.inlineValues" = "on";

        # ─────────────────────────────────────────────────────────────
        # Privacy & Accessibility
        # ─────────────────────────────────────────────────────────────
        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;
        "security.workspace.trust.untrustedFiles" = "open";
        "editor.accessibilitySupport" = "off";
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
