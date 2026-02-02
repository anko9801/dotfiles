{
  config,
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
}
