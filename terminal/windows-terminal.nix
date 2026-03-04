# Windows Terminal configuration (generated from theme.colors)
{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.windows-terminal;
  inherit (config.theme) colors;
  fonts = config.stylix.fonts or { };

  directions = [
    "left"
    "down"
    "up"
    "right"
  ];

  mkDirectionAction = action: dir: {
    command = {
      inherit action;
      direction = dir;
    };
    id = "User.${action}.${dir}";
  };

  mkDirectionActions = action: map (mkDirectionAction action) directions;

  tabIndices = lib.range 0 4;

  mkSwitchTabAction = i: {
    command = {
      action = "switchToTab";
      index = i;
    };
    id = "User.switchToTab.${toString i}";
  };

  mkBinding = id: keys: { inherit id keys; };

  directionKeys = {
    moveFocus = [
      "alt+left"
      "alt+down"
      "alt+up"
      "alt+right"
    ];
    resizePane = [
      "alt+shift+left"
      "alt+shift+down"
      "alt+shift+up"
      "alt+shift+right"
    ];
  };

  mkDirectionBindings =
    action: keys: lib.zipListsWith (dir: key: mkBinding "User.${action}.${dir}" key) directions keys;

  # Convert theme colors to Windows Terminal scheme
  colorScheme = {
    name = "Catppuccin Mocha";
    background = colors.base;
    foreground = colors.text;
    cursorColor = colors.rosewater;
    selectionBackground = colors.surface2;
    black = colors.surface1;
    brightBlack = colors.surface2;
    inherit (colors) red;
    brightRed = colors.red;
    inherit (colors) green;
    brightGreen = colors.green;
    inherit (colors) yellow;
    brightYellow = colors.yellow;
    inherit (colors) blue;
    brightBlue = colors.blue;
    purple = colors.pink;
    brightPurple = colors.pink;
    cyan = colors.teal;
    brightCyan = colors.teal;
    white = colors.subtext1;
    brightWhite = colors.subtext0;
  };

  defaultSettings = {
    "$help" = "https://aka.ms/terminal-documentation";
    "$schema" = "https://aka.ms/terminal-profiles-schema";
    defaultProfile = "{2c4de342-38b7-51cf-b940-2309a097f518}";
    copyOnSelect = false;
    copyFormatting = "none";
    language = "ja";

    profiles = {
      defaults = {
        colorScheme = colorScheme.name;
        font = {
          face = fonts.monospace.name or "Moralerspace Neon";
          size = 9;
        };
        padding = "0";
        antialiasingMode = "grayscale";
        cursorShape = "bar";
      };
      list = [
        {
          guid = "{2c4de342-38b7-51cf-b940-2309a097f518}";
          name = "Ubuntu";
          source = "Windows.Terminal.Wsl";
          startingDirectory = "~";
        }
        {
          guid = "{574e775e-4f2a-5b96-ac1e-a2962a402336}";
          name = "PowerShell";
          source = "Windows.Terminal.PowershellCore";
          hidden = false;
        }
        {
          guid = "{e7f51a44-2e34-4157-879f-1284f9841f09}";
          name = "Windows PowerShell";
          commandline = "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe";
          hidden = false;
        }
        {
          guid = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}";
          name = "Windows PowerShell (Administrator)";
          commandline = "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe";
          elevate = true;
          hidden = false;
        }
        {
          guid = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}";
          name = "Command Prompt";
          commandline = "%SystemRoot%\\System32\\cmd.exe";
          hidden = false;
        }
        {
          guid = "{12f1be4c-6e7c-4897-8343-f8402f539b26}";
          name = "Command Prompt (Administrator)";
          commandline = "%SystemRoot%\\System32\\cmd.exe";
          elevate = true;
          hidden = false;
        }
      ];
    };

    schemes = [ colorScheme ];

    actions = [
      {
        command = {
          action = "copy";
          singleLine = false;
        };
        id = "User.copy";
      }
      {
        command = "paste";
        id = "User.paste";
      }
      {
        command = "find";
        id = "User.find";
      }
      {
        command = {
          action = "splitPane";
          split = "down";
        };
        id = "User.splitPane.down";
      }
      {
        command = {
          action = "splitPane";
          split = "right";
        };
        id = "User.splitPane.right";
      }
      {
        command = "closePane";
        id = "User.closePane";
      }
      {
        command = "togglePaneZoom";
        id = "User.togglePaneZoom";
      }
    ]
    ++ mkDirectionActions "moveFocus"
    ++ mkDirectionActions "resizePane"
    ++ [
      {
        command.action = "newTab";
        id = "User.newTab";
      }
      {
        command.action = "closeTab";
        id = "User.closeTab";
      }
      {
        command.action = "prevTab";
        id = "User.prevTab";
      }
      {
        command.action = "nextTab";
        id = "User.nextTab";
      }
    ]
    ++ map mkSwitchTabAction tabIndices;

    keybindings = [
      (mkBinding "User.copy" "ctrl+shift+c")
      (mkBinding "User.paste" "ctrl+shift+v")
      (mkBinding "User.find" "ctrl+shift+f")
      (mkBinding "User.splitPane.down" "alt+shift+minus")
      (mkBinding "User.splitPane.right" "alt+shift+plus")
    ]
    ++ mkDirectionBindings "moveFocus" directionKeys.moveFocus
    ++ mkDirectionBindings "resizePane" directionKeys.resizePane
    ++ [
      (mkBinding "User.closePane" "ctrl+shift+w")
      (mkBinding "User.togglePaneZoom" "alt+shift+z")
      (mkBinding "User.newTab" "ctrl+shift+t")
      (mkBinding "User.closeTab" "ctrl+shift+w")
      (mkBinding "User.prevTab" "ctrl+shift+tab")
      (mkBinding "User.nextTab" "ctrl+tab")
    ]
    ++ lib.imap0 (
      i: _: mkBinding "User.switchToTab.${toString i}" "ctrl+alt+${toString (i + 1)}"
    ) tabIndices;
  };
in
{
  options.programs.windows-terminal = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.platform.os == "windows";
      description = "Windows Terminal configuration (auto-enabled for Windows)";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional settings to merge with defaults";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."windows-terminal/settings.json".text = builtins.toJSON (
      lib.recursiveUpdate defaultSettings cfg.settings
    );
  };
}
