{
  config,
  pkgs,
  lib,
  unfree-pkgs,
  ...
}:

let
  unfreePkgs = unfree-pkgs;
in
{
  home.packages = [
    unfreePkgs._1password-cli
  ];

  # sops-nix secrets management
  # Setup:
  #   1. Generate age key: age-keygen -o ~/.config/sops/age/keys.txt
  #   2. Create .sops.yaml with your public key
  #   3. Create secrets/secrets.yaml and encrypt with sops
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    # defaultSopsFile = ../secrets/secrets.yaml;
    # Example secret:
    # secrets.github_token = { };
  };

  xdg.configFile."op/config".text = builtins.toJSON {
    latest_signin = "";
    device = config.home.username;
    commands.biometric_unlock = true;
    cache.session.ttl = 1800;
  };

  services.gpg-agent = lib.mkIf (!(config.targets.genericLinux.enable or false)) {
    enable = true;
    enableSshSupport = false;
    enableZshIntegration = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
    pinentry.package = pkgs.pinentry-curses;
  };

  programs = {
    gpg = {
      enable = true;
      settings = {
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        keyserver = "hkps://keys.openpgp.org";
        keyid-format = "0xlong";
        with-fingerprint = true;
        require-cross-certification = true;
        no-symkey-cache = true;
        throw-keyids = true;
      };
    };

    # password-store removed (using 1Password instead)

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    nix-index-database.comma.enable = true;
  };
}
