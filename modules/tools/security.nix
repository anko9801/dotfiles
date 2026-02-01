{
  config,
  pkgs,
  lib,
  unfree-pkgs,
  ...
}:

let
  unfreePkgs = unfree-pkgs;
  isWSL = config.programs.wsl.windowsUser or null != null;
in
{
  # WSL uses op.exe from Windows, so skip Nix 1password-cli
  home.packages = lib.optionals (!isWSL) [
    unfreePkgs._1password-cli
  ];

  # 1Password CLI config - op doesn't accept symlinks and requires strict permissions
  home.activation.opConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ~/.config/op
        chmod 700 ~/.config/op
        if [[ ! -f ~/.config/op/config ]] || [[ -L ~/.config/op/config ]]; then
          rm -f ~/.config/op/config
          cat > ~/.config/op/config << 'EOF'
    {"latest_signin":"","device":"${config.home.username}","commands":{"biometric_unlock":true},"cache":{"session":{"ttl":1800}}}
    EOF
        fi
        chmod 600 ~/.config/op/config
  '';

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
