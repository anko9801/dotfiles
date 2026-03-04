# 1Password CLI configuration
# Sets defaults.ssh.agentSocket/signProgram for ssh.nix to consume
{
  config,
  lib,
  inputs,
  unfreePkgs,
  ...
}:

let
  p = config.platform;

  agentSocket =
    if p.os == "darwin" then
      "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else if p.environment == "wsl" then
      "$HOME/.1password/agent.sock"
    else
      "~/.1password/agent.sock";

  signProgram =
    if p.os == "darwin" then
      "${p.macAppsPath}/1Password.app/Contents/MacOS/op-ssh-sign"
    else if p.environment == "wsl" then
      "op-ssh-sign-wsl.exe"
    else
      "op-ssh-sign";
in
{
  imports = [ inputs._1password-shell-plugins.hmModules.default ];

  config = {
    defaults.ssh = {
      inherit agentSocket signProgram;
    };

    # WSL uses op.exe from Windows, so skip Nix 1password-cli
    home.packages = lib.optionals (p.environment != "wsl") [
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
  };
}
