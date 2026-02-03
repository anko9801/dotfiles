{ pkgs, ... }:

{
  home.packages = with pkgs; [
    niri
    xwayland-satellite # XWayland support
    wl-clipboard
    cliphist # Clipboard history
    swww # Wallpaper
    brightnessctl
    playerctl
    pamixer
    grim # Screenshot
    slurp # Region selection
    satty # Screenshot annotation
  ];

  xdg.configFile."niri/config.kdl".text = ''
    input {
      keyboard {
        xkb {
          layout "jp"
        }
        repeat-delay 300
        repeat-rate 60
      }
      touchpad {
        tap
        natural-scroll
        dwt // disable while typing
      }
      mouse {}
      warp-mouse-to-focus
    }

    output "eDP-1" {
      scale 1.0
    }

    layout {
      gaps 12
      center-focused-column "never"

      preset-column-widths {
        proportion 0.33
        proportion 0.5
        proportion 0.66
      }
      default-column-width { proportion 0.5; }

      focus-ring {
        width 2
        active-color "#7aa2f7"
        inactive-color "#414868"
      }

      border {
        off
      }

      shadow {
        on
        softness 10
        spread 2
        offset x=0 y=4
        color "#00000050"
      }

      struts {}
    }

    cursor {
      xcursor-theme "Adwaita"
      xcursor-size 24
    }

    prefer-no-csd
    screenshot-path "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"

    animations {}

    window-rule {
      geometry-corner-radius 8
      clip-to-geometry true
    }

    // Floating windows
    window-rule {
      match app-id=r#"pavucontrol"#
      open-floating true
    }
    window-rule {
      match app-id=r#"blueman"#
      open-floating true
    }

    spawn-at-startup "swaync"
    spawn-at-startup "swww-daemon"
    spawn-at-startup "xwayland-satellite"

    binds {
      // Launch
      Mod+Return { spawn "ghostty"; }
      Mod+Space { spawn "fuzzel"; }
      Mod+E { spawn "nautilus"; }

      // Window management (Shift for destructive actions)
      Mod+Shift+Q { close-window; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+Shift+Space { toggle-window-floating; }
      Mod+C { center-column; }

      // Focus (vim-style)
      Mod+H { focus-column-left; }
      Mod+J { focus-window-down; }
      Mod+K { focus-window-up; }
      Mod+L { focus-column-right; }
      Mod+Left { focus-column-left; }
      Mod+Down { focus-window-down; }
      Mod+Up { focus-window-up; }
      Mod+Right { focus-column-right; }

      // Move window
      Mod+Ctrl+H { move-column-left; }
      Mod+Ctrl+J { move-window-down; }
      Mod+Ctrl+K { move-window-up; }
      Mod+Ctrl+L { move-column-right; }
      Mod+Ctrl+Left { move-column-left; }
      Mod+Ctrl+Down { move-window-down; }
      Mod+Ctrl+Up { move-window-up; }
      Mod+Ctrl+Right { move-column-right; }

      // Monitor focus
      Mod+Shift+H { focus-monitor-left; }
      Mod+Shift+J { focus-monitor-down; }
      Mod+Shift+K { focus-monitor-up; }
      Mod+Shift+L { focus-monitor-right; }

      // Move to monitor
      Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

      // Workspace
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }
      Mod+Page_Up { focus-workspace-up; }
      Mod+Page_Down { focus-workspace-down; }
      Mod+U { focus-workspace-up; }
      Mod+I { focus-workspace-down; }

      // Column/window sizing
      Mod+R { switch-preset-column-width; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }

      // Column operations
      Mod+BracketLeft { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }
      Mod+Comma { consume-window-into-column; }
      Mod+Period { expel-window-from-column; }
      Mod+W { toggle-column-tabbed-display; }

      // Scroll (mouse)
      Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
      Mod+WheelScrollRight { focus-column-right; }
      Mod+WheelScrollLeft { focus-column-left; }

      // Screenshot
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Mod+Print { screenshot-window; }
      Mod+Shift+S { spawn "sh" "-c" "grim -g \"$(slurp)\" - | satty -f -"; }

      // Media keys
      XF86AudioRaiseVolume { spawn "pamixer" "-i" "5"; }
      XF86AudioLowerVolume { spawn "pamixer" "-d" "5"; }
      XF86AudioMute { spawn "pamixer" "-t"; }
      XF86AudioPlay { spawn "playerctl" "play-pause"; }
      XF86AudioNext { spawn "playerctl" "next"; }
      XF86AudioPrev { spawn "playerctl" "previous"; }
      XF86MonBrightnessUp { spawn "brightnessctl" "set" "+5%"; }
      XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

      // System
      Mod+Shift+E { quit; }
      Mod+Shift+P { power-off-monitors; }
      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
    }
  '';
}
