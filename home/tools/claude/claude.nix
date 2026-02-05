{ unfreePkgs, ... }:

let
  sessionStartFile = "\${XDG_RUNTIME_DIR:-/tmp}/.claude_session_start";

  lintHook = ''
    # Run project-specific linters if they exist
    if [ -f "package.json" ] && grep -q '"lint"' package.json 2>/dev/null; then
      npm run lint --if-present 2>&1 || exit 2
    elif [ -f "Cargo.toml" ]; then
      cargo clippy --quiet 2>&1 || exit 2
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
      ruff check . 2>&1 || exit 2
    elif [ -f "flake.nix" ]; then
      nix flake check 2>&1 | head -20 || exit 2
    fi
  '';
in
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

      # Hooks - run commands at specific lifecycle points
      # Exit code 0 = success, 2 = blocking error (stderr fed back to Claude)
      hooks = {
        # Before tool use - block dangerous commands and track start time
        PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = ''
                  # Block dangerous commands
                  if echo "$CLAUDE_TOOL_INPUT" | grep -qE '\b(rm\s+-rf\s+/|dd\s+if=|mkfs\.|>\s*/dev/sd)'; then
                    echo "Blocked: potentially destructive command" >&2
                    exit 2
                  fi
                '';
              }
            ];
          }
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = ''
                  # Record session start time (only if not already set)
                  start_file="${sessionStartFile}"
                  [ ! -f "$start_file" ] && date +%s > "$start_file"
                '';
              }
            ];
          }
        ];
        # After file edits, run linters if available
        PostToolUse =
          map
            (matcher: {
              inherit matcher;
              hooks = [
                {
                  type = "command";
                  command = lintHook;
                }
              ];
            })
            [
              "Write"
              "Edit"
            ];
        # Notify when Claude needs input
        Notification = [
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = "echo '🔔 Claude needs your input' >&2";
              }
            ];
          }
        ];
        # Task completion notification (only for tasks > 30s)
        Stop = [
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = ''
                  start_file="${sessionStartFile}"
                  if [ -f "$start_file" ]; then
                    start_time=$(cat "$start_file")
                    elapsed=$(($(date +%s) - start_time))
                    rm -f "$start_file"
                    # Only notify if task took longer than 30 seconds
                    if [ "$elapsed" -ge 30 ]; then
                      # WSL notification (BurntToast)
                      if grep -qi microsoft /proc/version 2>/dev/null; then
                        powershell.exe -Command "New-BurntToastNotification -Text 'Claude Code', 'Task completed (''${elapsed}s)'" 2>/dev/null || true
                      # macOS notification
                      elif command -v osascript &>/dev/null; then
                        osascript -e "display notification \"Task completed (''${elapsed}s)\" with title \"Claude Code\""
                      # Linux notification (notify-send)
                      elif command -v notify-send &>/dev/null; then
                        notify-send "Claude Code" "Task completed (''${elapsed}s)"
                      fi
                    fi
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
