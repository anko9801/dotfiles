# Custom overlays for nixpkgs
# Add custom package modifications or overrides here

final: prev: {
  # Example: Override a package version
  # myPackage = prev.myPackage.overrideAttrs (oldAttrs: {
  #   version = "1.2.3";
  #   src = prev.fetchFromGitHub {
  #     owner = "example";
  #     repo = "myPackage";
  #     rev = "v1.2.3";
  #     sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  #   };
  # });
}
