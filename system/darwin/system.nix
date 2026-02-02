_:

{
  # macOS system preferences
  system = {
    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      # Dock settings
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.5;
        orientation = "bottom";
        show-recents = false;
        tilesize = 48;
        minimize-to-application = true;
        mru-spaces = false; # Don't rearrange spaces based on most recent use
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv"; # List view
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      # Global settings
      NSGlobalDomain = {
        # Keyboard
        ApplePressAndHoldEnabled = false; # Enable key repeat
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        # UI
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Always";
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        # Mouse/Trackpad
        "com.apple.mouse.tapBehavior" = 1; # Tap to click
        "com.apple.trackpad.scaling" = 2.0;

        # Behavior
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };

      # Trackpad settings
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      # Menu bar clock
      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 1;
        ShowDayOfWeek = true;
        ShowSeconds = false;
      };

      # Login window
      loginwindow = {
        GuestEnabled = false;
      };

      # Screenshots
      screencapture = {
        location = "~/Pictures/Screenshots";
        type = "png";
        disable-shadow = true;
      };

      # Spaces
      spaces = {
        spans-displays = false;
      };

      # Custom preferences
      CustomUserPreferences = {
        # TextEdit - use plain text by default
        "com.apple.TextEdit" = {
          RichText = 0;
          PlainTextEncoding = 4;
          PlainTextEncodingForWrite = 4;
        };

        # Disable disk image verification
        "com.apple.frameworks.diskimages" = {
          skip-verify = true;
          skip-verify-locked = true;
          skip-verify-remote = true;
        };

        # Activity Monitor - show all processes
        "com.apple.ActivityMonitor" = {
          ShowCategory = 0;
          SortColumn = "CPUUsage";
          SortDirection = 0;
        };
      };
    };

  };
}
