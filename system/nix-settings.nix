# Common Nix settings shared across all platforms (darwin, nixos, home-manager)
{
  settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Binary caches (reduces build time for common packages)
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
    # Evaluation caching (requires flakes)
    accept-flake-config = true;
    keep-derivations = true;
    keep-outputs = true;
    # Parallelization
    max-jobs = "auto";
  };

  # GC configuration (unified across platforms)
  gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # GC schedule: weekly (platform-specific formats)
  gcSchedule = {
    # nix-darwin (launchd interval: Sunday 3:00 AM)
    darwin = {
      Weekday = 0; # 0 = Sunday
      Hour = 3;
      Minute = 0;
    };
    # NixOS / home-manager (systemd timer)
    frequency = "weekly";
  };
}
