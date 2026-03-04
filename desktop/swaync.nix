{ config, ... }:

let
  c = config.theme.colors;
in
{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 0;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 5;
      timeout-low = 3;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 400;
      control-center-height = 600;
      notification-window-width = 400;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      scripts = { };
      notification-visibility = { };
      widgets = [
        "inhibitors"
        "title"
        "dnd"
        "notifications"
        "mpris"
      ];
      widget-config = {
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear";
          clear-all-button = true;
        };
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        mpris = {
          image-size = 96;
          image-radius = 8;
        };
      };
    };
    style = ''
      * {
        font-family: "monospace";
        font-size: 13px;
      }

      .notification-row {
        outline: none;
      }

      .notification {
        border-radius: 8px;
        margin: 6px;
        padding: 0;
        background: ${c.base};
        border: 1px solid ${c.surface1};
      }

      .notification-content {
        padding: 12px;
      }

      .notification-default-action,
      .notification-action {
        padding: 6px;
        margin: 0;
        border-radius: 6px;
      }

      .notification-default-action:hover,
      .notification-action:hover {
        background: ${c.surface0};
      }

      .close-button {
        background: ${c.red};
        color: ${c.base};
        border-radius: 50%;
        margin: 6px;
        padding: 2px;
      }

      .close-button:hover {
        background: ${c.peach};
      }

      .summary {
        color: ${c.text};
        font-weight: bold;
      }

      .body {
        color: ${c.subtext1};
      }

      .control-center {
        background: ${c.base}ee;
        border-radius: 12px;
        border: 1px solid ${c.surface1};
        margin: 10px;
      }

      .control-center-list {
        background: transparent;
      }

      .widget-title {
        color: ${c.blue};
        font-weight: bold;
        padding: 8px 12px;
      }

      .widget-title > button {
        background: ${c.blue};
        color: ${c.base};
        border-radius: 6px;
        padding: 4px 12px;
      }

      .widget-title > button:hover {
        background: ${c.sky};
      }

      .widget-dnd {
        padding: 8px 12px;
        color: ${c.text};
      }

      .widget-dnd > switch {
        border-radius: 12px;
        background: ${c.surface1};
      }

      .widget-dnd > switch:checked {
        background: ${c.blue};
      }

      .widget-mpris {
        padding: 8px;
      }
    '';
  };
}
