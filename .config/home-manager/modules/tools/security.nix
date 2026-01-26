{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    _1password-cli # 1Password CLI (op)
  ];

  # 1Password CLI configuration
  xdg.configFile."op/config".text = builtins.toJSON {
    latest_signin = "";
    device = config.home.username;
    commands = {
      biometric_unlock = true;
    };
    cache = {
      session = {
        ttl = 1800;
      };
    };
  };

  # GPG configuration
  programs.gpg = {
    enable = true;
    settings = {
      # Use strong algorithms
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";

      # Key server
      keyserver = "hkps://keys.openpgp.org";

      # Display options
      keyid-format = "0xlong";
      with-fingerprint = true;

      # Security
      require-cross-certification = true;
      no-symkey-cache = true;
      throw-keyids = true;
    };
  };

  # GPG Agent (Linux only - not on WSL typically)
  services.gpg-agent = lib.mkIf (!config.targets.genericLinux.enable or false) {
    enable = true;
    enableSshSupport = false; # Using 1Password for SSH
    enableZshIntegration = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # Password store (pass)
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
      PASSWORD_STORE_CLIP_TIME = "45";
    };
  };

  # nix-index for command-not-found
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # comma - run programs without installing
  programs.nix-index-database.comma.enable = true;
}
