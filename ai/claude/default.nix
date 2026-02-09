{
  unfreePkgs,
  antfu-skills ? null,
  lib,
  ...
}:

let
  sessionDir = "\${XDG_RUNTIME_DIR:-/tmp}/claude-session";

in
{
  # MCP settings file
  home.file.".claude/mcp_settings.json".source = ./mcp_settings.json;

  # External skills (antfu/skills - Vue/Vite/Nuxt ecosystem)
  programs.agent-skills = lib.mkIf (antfu-skills != null) {
    enable = true;
    sources.antfu.path = antfu-skills;
    skills.enableAll = [ "antfu" ];
    targets.claude = {
      enable = true;
      dest = ".claude/skills";
      structure = "symlink-tree";
    };
  };

  programs.claude-code = {
    enable = true;
    package = unfreePkgs.claude-code;

    # CLAUDE.md (memory)
    memory.source = ./CLAUDE.md;

    # Rules directory (always loaded)
    rulesDir = ./rules;

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

      # Hooks - run commands at specific lifecycle points
      # Exit code 0 = success, 2 = blocking error (stderr fed back to Claude)
      hooks = {
        # Block dangerous commands (uses case for speed, no subprocess)
        PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = ''
                  case "$CLAUDE_TOOL_INPUT" in
                    *"rm -rf /"*|*"dd if="*|*"mkfs."*|*"> /dev/sd"*)
                      echo "Blocked: potentially destructive command" >&2
                      exit 2 ;;
                  esac
                  # Track session start time
                  mkdir -p "${sessionDir}"
                  [ ! -f "${sessionDir}/start" ] && date +%s > "${sessionDir}/start"
                '';
              }
            ];
          }
        ];
        # Task completion notification (only for tasks > 30s, runs async)
        Stop = [
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = ''
                  f="${sessionDir}/start"; [ -f "$f" ] || exit 0
                  read -r start < "$f"; rm "$f"
                  elapsed=$(($(date +%s) - start)); [ "$elapsed" -ge 30 ] || exit 0
                  # Async notification
                  if [ -n "$WSL_DISTRO_NAME" ]; then
                    powershell.exe -Command "New-BurntToastNotification -Text 'Claude Code', 'Done (''${elapsed}s)'" 2>/dev/null &
                  elif [ -n "$DISPLAY" ]; then
                    notify-send "Claude Code" "Done (''${elapsed}s)" 2>/dev/null &
                  elif [ "$(uname)" = Darwin ]; then
                    osascript -e "display notification \"Done (''${elapsed}s)\" with title \"Claude Code\"" &
                  fi
                '';
              }
            ];
          }
        ];
      };
    };
  };
}
