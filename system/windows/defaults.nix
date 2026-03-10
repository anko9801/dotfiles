_: {
  system.registry.HKCU = {
    Software.Microsoft.Windows.CurrentVersion.Explorer.Advanced = {
      HideFileExt = 0;
      Hidden = 1;
      LaunchTo = 1;
    };
    Software.Policies.Microsoft.Windows.Explorer = {
      DisableSearchBoxSuggestions = 1;
    };
  };

  environment = {
    variables.EDITOR = "code --wait";
    userPath = [ "%USERPROFILE%\\go\\bin" ];
  };
}
