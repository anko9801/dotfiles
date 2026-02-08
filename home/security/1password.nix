{
  config,
  lib,
  unfreePkgs,
  ...
}:

let
  inherit (config.platform) isDarwin isWSL;
in
{
  options.tools.onePassword = {
    agentSocket = lib.mkOption {
      type = lib.types.str;
      description = "Path to 1Password SSH agent socket";
    };

    signProgram = lib.mkOption {
      type = lib.types.str;
      description = "Path to 1Password SSH signing program";
    };

    cliPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to 1Password CLI (op)";
    };
  };

  config = {
    # Platform-specific 1Password paths
    tools.onePassword = lib.mkMerge [
      # Default (Linux desktop)
      {
        agentSocket = lib.mkDefault "~/.1password/agent.sock";
        signProgram = lib.mkDefault "op-ssh-sign";
        cliPath = lib.mkDefault "op";
      }
      # macOS
      (lib.mkIf isDarwin {
        agentSocket = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        signProgram = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        cliPath = "/Applications/1Password.app/Contents/MacOS/op";
      })
      # WSL (uses Windows binaries)
      (lib.mkIf isWSL {
        agentSocket = "$HOME/.1password/agent.sock";
        signProgram = "/mnt/c/Users/${config.programs.wsl.windowsUser}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe";
        cliPath = "/mnt/c/Users/${config.programs.wsl.windowsUser}/AppData/Local/Microsoft/WinGet/Links/op.exe";
      })
    ];

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
  };
}
