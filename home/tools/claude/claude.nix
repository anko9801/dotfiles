{ unfreePkgs, config, ... }:

{
  # MCP settings file
  home.file.".claude/mcp_settings.json".source = ./mcp_settings.json;

  programs.claude-code = {
    enable = true;
    package = unfreePkgs.claude-code;

    # CLAUDE.md (memory)
    memory.source = ./CLAUDE.md;

    # Agents directory
    agentsDir = ./agents;

    # Commands directory
    commandsDir = ./commands;

    # Settings
    settings = {
      terminalStatusLine = "disabled";
      permissions = {
        tools = {
          allowedCommands = [
            "git"
            "npm"
            "yarn"
            "pnpm"
            "mise"
            "cargo"
            "rustc"
            "go"
            "python"
            "pip"
            "uv"
            "ruff"
            "make"
            "cmake"
            "docker"
            "docker-compose"
            "kubectl"
            "terraform"
            "curl"
            "wget"
            "ls"
            "cat"
            "grep"
            "rg"
            "fd"
            "find"
            "sed"
            "sd"
            "awk"
            "tree"
            "which"
            "echo"
            "printf"
            "test"
            "mkdir"
            "rm"
            "cp"
            "mv"
            "touch"
            "chmod"
            "chown"
            "brew"
            "apt"
            "pacman"
            "dnf"
            "zypper"
            "apk"
            "gh"
            "glab"
          ];
          deniedCommands = [
            "sudo"
            "su"
            "passwd"
            "shutdown"
            "reboot"
            "systemctl"
            "service"
            "dd"
            "format"
            "fdisk"
            "mkfs"
            "mount"
            "umount"
            "killall"
            "pkill"
            "nc"
            "netcat"
            "nmap"
            "ssh"
            "scp"
            "rsync"
            "telnet"
            "ftp"
          ];
        };
      };
      experimental = {
        alwaysAllowedCommands = [
          "git status"
          "git diff"
          "git log"
          "ls -la"
          "pwd"
          "echo $PATH"
          "which"
          "env | grep -E '^(PATH|HOME|USER|SHELL)='"
        ];
      };
    };
  };
}
