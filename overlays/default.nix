{ inputs, ... }:
{
  # Access stable packages via pkgs.stable.*
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = false;
    };
  };
}
