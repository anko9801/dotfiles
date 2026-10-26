_: {
  homebrew.casks = [ "itsycal" ];
  system.defaults.CustomUserPreferences."com.mowglii.ItsycalApp" = {
    ShowWeeks = true;
    WeekStartDOW = 1;
    ShowEventDays = 7;
    ShowLocation = true;
    SizePreference = 0;
    PinItsycal = false;
    SUEnableAutomaticChecks = false;
  };
}
