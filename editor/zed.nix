{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Zed - high-performance editor
  # Only enable on non-WSL platforms (WSL should use Windows Zed)
  programs.zed-editor = lib.mkIf (!(config.targets.genericLinux.enable or false)) {
    enable = true;
    package = pkgs.zed-editor;

    userSettings = {
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # Theme and fonts managed by Stylix

      vim_mode = true;
      relative_line_numbers = true;
      cursor_blink = false;

      tab_size = 2;
      format_on_save = "on";
      autosave = "on_focus_change";

      inlay_hints.enabled = false;
      scrollbar.show = "never";
      minimap.show = "never";
      indent_guides.enabled = true;

      git = {
        inline_blame.enabled = true;
        git_gutter = "tracked_files";
      };

      terminal.copy_on_select = true;

      languages = {
        Python.tab_size = 4;
        Rust.tab_size = 4;
        Go.tab_size = 4;
      };
    };

    userKeymaps = [
      {
        context = "Editor && vim_mode == insert";
        bindings = {
          "j k" = "vim::NormalBefore";
        };
      }
    ];
  };
}
