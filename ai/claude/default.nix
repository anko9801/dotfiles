{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:

let
  antfu-skills = inputs.antfu-skills or null;
  anthropic-skills = inputs.anthropic-skills or null;
  sessionDir = "\${XDG_RUNTIME_DIR:-/tmp}/claude-session";
in
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.ccusage
  ];

  programs.agent-skills = {
    enable = true;
    sources =
      lib.optionalAttrs (antfu-skills != null) {
        antfu.path = antfu-skills;
      }
      // lib.optionalAttrs (anthropic-skills != null) {
        anthropic = {
          path = anthropic-skills;
          subdir = "skills";
        };
      };
    skills.enableAll = [
      "antfu"
      "anthropic"
    ];
    targets = {
      claude = {
        enable = true;
        dest = ".claude/skills";
        structure = "symlink-tree";
      };
      codex = {
        enable = true;
        dest = ".codex/skills";
        structure = "copy-tree";
      };
    };
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code-bin;

    # CLAUDE.md (memory)
    memory.source = ./CLAUDE.md;

    # Rules directory (always loaded)
    rulesDir = ./rules;

    # Agents directory
    agentsDir = ./agents;

    # Commands directory
    commandsDir = ./commands;

    mcpServers = {
      github = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@anthropic-ai/claude-code-github-mcp"
        ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "$(gh auth token)";
        };
      };
      filesystem = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@anthropic-ai/claude-code-filesystem-mcp"
          config.home.homeDirectory
        ];
      };
    };

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
