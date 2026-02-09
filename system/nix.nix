# Nix daemon settings shared across all platforms
{
  settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    accept-flake-config = true;
    keep-derivations = true;
    keep-outputs = true;
    max-jobs = "auto";
  };
  gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
  gcSchedule = {
    darwin = {
      Weekday = 0;
      Hour = 3;
      Minute = 0;
    };
    frequency = "weekly";
  };
}
