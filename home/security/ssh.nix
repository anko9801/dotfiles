{
  lib,
  pkgs,
  config,
  userConfig,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin isLinux;
  isWSL = config.programs.wsl.windowsUser != null;
in
{
  options = {
    tools.ssh = {
      onePasswordAgentPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "~/.1password/agent.sock";
        description = "Path to 1Password SSH agent socket (null to disable)";
      };

      onePasswordSignProgram = lib.mkOption {
        type = lib.types.str;
        default = "op-ssh-sign";
        description = "Path to 1Password SSH signing program";
      };
    };

    programs.wsl.windowsUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Windows username for WSL integration paths";
    };
  };

  config = {
    # Platform-specific 1Password paths
    tools.ssh = lib.mkMerge [
      (lib.mkIf isDarwin {
        onePasswordAgentPath = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        onePasswordSignProgram = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      })
      (lib.mkIf isWSL {
        onePasswordAgentPath = "$HOME/.1password/agent.sock";
        onePasswordSignProgram = "/mnt/c/Users/${config.programs.wsl.windowsUser}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe";
      })
    ];

    # Platform-specific SSH_AUTH_SOCK
    home.sessionVariables = lib.mkMerge [
      (lib.mkIf isDarwin {
        SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      })
      (lib.mkIf isLinux {
        SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
      })
    ];

    programs.ssh = {
      enable = true;
      enableDefaultConfig = lib.mkDefault false;

      # WSL: no IdentityAgent (agent forwarded via npiperelay)
      # macOS/Linux: IdentityAgent pointing to 1Password socket
      extraConfig = lib.mkMerge [
        (lib.mkIf isDarwin ''
          IdentityAgent "${config.tools.ssh.onePasswordAgentPath}"
        '')
        (lib.mkIf (isLinux && !isWSL) ''
          IdentityAgent ${config.tools.ssh.onePasswordAgentPath}
        '')
      ];

      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
        };

        "github.com" = {
          hostname = "github.com";
          user = "git";
        };
        "gitlab.com" = {
          hostname = "gitlab.com";
          user = "git";
        };
      }
      // (lib.mapAttrs (_: host: {
        inherit (host) hostname user;
        identityFile = "~/.ssh/id_ed25519";
      }) userConfig.sshHosts);
    };

    # Git SSH signing configuration (uses platform-specific program)
    programs.git.settings = {
      gpg.format = "ssh";
      gpg.ssh.program = config.tools.ssh.onePasswordSignProgram;
    };
  };
}
