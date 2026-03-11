{ pkgs, ... }:

{
  imports = [
    ./homebrew.nix
    ../../desktop/aerospace.nix
    ../../desktop/sketchybar
    ../../desktop/raycast
    (import ../../desktop/kanata.nix).darwinModule
  ];

  # Register fonts with macOS Font Book (home-manager fonts aren't visible to GUI apps)
  fonts.packages = with pkgs; [
    moralerspace
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];

  # Enable Touch ID for sudo (including inside tmux via pam_reattach)
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # macOS system preferences
  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.5;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
        minimize-to-application = true;
        mru-spaces = false;
        persistent-apps = [
          "/Applications/Arc.app"
          "/Applications/Claude.app"
          "/Applications/cmux.app"
          "/Applications/Slack.app"
          "/Applications/Discord.app"
          "/Applications/Notion.app"
          "/Applications/Spotify.app"
          "/System/Applications/Utilities/Activity Monitor.app"
          "/System/Applications/System Settings.app"
        ];
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        _FXSortFoldersFirst = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      NSGlobalDomain = {
        _HIHideMenuBar = true;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Always";
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.trackpad.scaling" = 2.0;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
        FirstClickThreshold = 0;
        SecondClickThreshold = 0;
      };

      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 1;
        ShowDayOfWeek = true;
        ShowSeconds = false;
      };

      loginwindow.GuestEnabled = false;

      screencapture = {
        location = "~/Pictures/Screenshots";
        type = "png";
        disable-shadow = true;
      };

      spaces.spans-displays = false;

      CustomUserPreferences = {
        "com.apple.WindowManager" = {
          EnableTiledWindowMargins = false;
        };
        "com.apple.finder" = {
          NewWindowTarget = "PfHm";
          FXDefaultSearchScope = "SCcf";
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.ImageCapture" = {
          disableHotPlug = true;
        };
        NSGlobalDomain = {
          "com.apple.keyboard.fnState" = true;
        };
        "com.apple.TextEdit" = {
          RichText = 0;
          PlainTextEncoding = 4;
          PlainTextEncodingForWrite = 4;
        };
        "com.apple.frameworks.diskimages" = {
          skip-verify = true;
          skip-verify-locked = true;
          skip-verify-remote = true;
        };
        "com.apple.ActivityMonitor" = {
          ShowCategory = 0;
          SortColumn = "CPUUsage";
          SortDirection = 0;
        };
        "com.apple.Accessibility" = {
          ReduceMotionEnabled = 1;
        };
        "com.apple.sound.uiaudio" = {
          enabled = false;
        };
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "64" = {
              enabled = false;
              value = {
                parameters = [
                  32
                  49
                  1048576
                ];
                type = "standard";
              };
            };
            "65" = {
              enabled = false;
              value = {
                parameters = [
                  32
                  49
                  1572864
                ];
                type = "standard";
              };
            };
          };
        };
      };
    };
  };
}
