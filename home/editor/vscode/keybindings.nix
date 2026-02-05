{
  config,
  lib,
  ...
}:

{
  programs.vscode = lib.mkIf (!(config.targets.genericLinux.enable or false)) {
    profiles.default.keybindings = [
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
}
