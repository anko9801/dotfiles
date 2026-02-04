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
        # vscode-neovim (uses actual Neovim instance)
        # ─────────────────────────────────────────────────────────────
        "vscode-neovim.neovimExecutablePaths.linux" = "nvim";
        "vscode-neovim.neovimExecutablePaths.darwin" = "nvim";
        "extensions.experimental.affinity"."asvetliakov.vscode-neovim" = 1;

        # ─────────────────────────────────────────────────────────────
        # Privacy
        # ─────────────────────────────────────────────────────────────
        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;
        "security.workspace.trust.untrustedFiles" = "open";
        "editor.accessibilitySupport" = "off";
      };

      keybindings = [
        # Terminal
        {
          key = "ctrl+`";
          command = "workbench.action.terminal.toggleTerminal";
        }

        # Suggestions (Ctrl+j/k for navigation)
        {
          key = "ctrl+j";
          command = "selectNextSuggestion";
          when = "suggestWidgetVisible";
        }
        {
          key = "ctrl+k";
          command = "selectPrevSuggestion";
          when = "suggestWidgetVisible";
        }

        # Quick open (Ctrl+j/k for navigation)
        {
          key = "ctrl+j";
          command = "workbench.action.quickOpenSelectNext";
          when = "inQuickOpen";
        }
        {
          key = "ctrl+k";
          command = "workbench.action.quickOpenSelectPrevious";
          when = "inQuickOpen";
        }

        # Panel navigation
        {
          key = "ctrl+h";
          command = "workbench.action.focusLeftGroup";
          when = "editorFocus";
        }
        {
          key = "ctrl+l";
          command = "workbench.action.focusRightGroup";
          when = "editorFocus";
        }

        # Explorer (Vim-like)
        {
          key = "a";
          command = "explorer.newFile";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "shift+a";
          command = "explorer.newFolder";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "r";
          command = "renameFile";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "d";
          command = "deleteFile";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "x";
          command = "filesExplorer.cut";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "y";
          command = "filesExplorer.copy";
          when = "filesExplorerFocus && !inputFocus";
        }
        {
          key = "p";
          command = "filesExplorer.paste";
          when = "filesExplorerFocus && !inputFocus";
        }

        # Sidebar toggle
        {
          key = "ctrl+e";
          command = "workbench.action.toggleSidebarVisibility";
          when = "!filesExplorerFocus";
        }
        {
          key = "ctrl+e";
          command = "workbench.action.focusActiveEditorGroup";
          when = "filesExplorerFocus";
        }

        # ─────────────────────────────────────────────────────────────
        # Neovim Normal mode (space leader)
        # ─────────────────────────────────────────────────────────────
        # Find
        {
          key = "space f f";
          command = "workbench.action.quickOpen";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space f g";
          command = "workbench.action.findInFiles";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space f b";
          command = "workbench.action.showAllEditors";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space f r";
          command = "workbench.action.openRecent";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }

        # Git
        {
          key = "space g g";
          command = "workbench.view.scm";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space g d";
          command = "git.openChange";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space g b";
          command = "gitlens.toggleFileBlame";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }

        # Code actions
        {
          key = "space c a";
          command = "editor.action.quickFix";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space c r";
          command = "editor.action.rename";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space c f";
          command = "editor.action.formatDocument";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }

        # Diagnostics
        {
          key = "space x x";
          command = "workbench.actions.view.problems";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "[ d";
          command = "editor.action.marker.prev";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "] d";
          command = "editor.action.marker.next";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }

        # Buffer/Window
        {
          key = "space w";
          command = "workbench.action.files.save";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space q";
          command = "workbench.action.closeActiveEditor";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space s v";
          command = "workbench.action.splitEditorRight";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }
        {
          key = "space s h";
          command = "workbench.action.splitEditorDown";
          when = "neovim.mode == 'normal' && editorTextFocus";
        }

        # ─────────────────────────────────────────────────────────────
        # runCommands (multiple actions)
        # ─────────────────────────────────────────────────────────────
        # Save all and format
        {
          key = "ctrl+shift+s";
          command = "runCommands";
          args.commands = [
            "editor.action.formatDocument"
            "workbench.action.files.saveAll"
          ];
          when = "editorTextFocus";
        }
        # Duplicate line and comment original
        {
          key = "ctrl+alt+c";
          command = "runCommands";
          args.commands = [
            "editor.action.copyLinesDownAction"
            "cursorUp"
            "editor.action.addCommentLine"
            "cursorDown"
          ];
          when = "editorTextFocus && !editorReadonly";
        }
      ];
    };
  };
}
