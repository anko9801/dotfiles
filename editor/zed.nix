{
  config,
  lib,
  pkgs,
  ...
}:

let
  guiEnabled = config.platform.hasNativeGui && builtins.getEnv "CI" != "true";
  inherit (pkgs.stdenv) isDarwin;

  settings = {
    telemetry = {
      diagnostics = false;
      metrics = false;
    };

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

  keymaps = [
    {
      context = "Editor && vim_mode == insert";
      bindings = {
        "j k" = "vim::NormalBefore";
      };
    }
  ];
in
{
  # NixOS/Linux: full HM module (package + config)
  programs.zed-editor = lib.mkIf (guiEnabled && !isDarwin) {
    enable = true;
    userSettings = settings;
    userKeymaps = keymaps;
  };

  # Darwin: config only (package from Homebrew)
  xdg.configFile = lib.mkIf (guiEnabled && isDarwin) {
    "zed/settings.json".text = builtins.toJSON settings;
    "zed/keymap.json".text = builtins.toJSON keymaps;
  };
}
