_:

{
  imports = [
    ./homebrew.nix
    ./aerospace.nix
    (import ../../tools/kanata).darwinModule
  ];

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

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
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      NSGlobalDomain = {
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
      };
    };
  };
}
