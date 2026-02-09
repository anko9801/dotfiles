{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.gpg-agent = lib.mkIf (!(config.targets.genericLinux.enable or false)) {
    enable = true;
    enableSshSupport = false;
    enableZshIntegration = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
    pinentry.package = pkgs.pinentry-curses;
  };

  programs.gpg = {
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
}
