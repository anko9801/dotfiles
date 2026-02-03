_:

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
        background: #1a1b26;
        border: 1px solid #414868;
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
        background: #33467c;
      }

      .close-button {
        background: #f7768e;
        color: #1a1b26;
        border-radius: 50%;
        margin: 6px;
        padding: 2px;
      }

      .close-button:hover {
        background: #ff9e64;
      }

      .summary {
        color: #c0caf5;
        font-weight: bold;
      }

      .body {
        color: #a9b1d6;
      }

      .control-center {
        background: #1a1b26ee;
        border-radius: 12px;
        border: 1px solid #414868;
        margin: 10px;
      }

      .control-center-list {
        background: transparent;
      }

      .widget-title {
        color: #7aa2f7;
        font-weight: bold;
        padding: 8px 12px;
      }

      .widget-title > button {
        background: #7aa2f7;
        color: #1a1b26;
        border-radius: 6px;
        padding: 4px 12px;
      }

      .widget-title > button:hover {
        background: #7dcfff;
      }

      .widget-dnd {
        padding: 8px 12px;
        color: #c0caf5;
      }

      .widget-dnd > switch {
        border-radius: 12px;
        background: #414868;
      }

      .widget-dnd > switch:checked {
        background: #7aa2f7;
      }

      .widget-mpris {
        padding: 8px;
      }
    '';
  };
}
