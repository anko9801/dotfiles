{ unfreePkgs, ... }:

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
        # Before tool use - block dangerous commands
        PreToolUse = [
          {
            matcher = "Bash";
            command = ''
              # Block dangerous commands
              if echo "$CLAUDE_TOOL_INPUT" | grep -qE '\b(rm\s+-rf\s+/|dd\s+if=|mkfs|:(){:|>\s*/dev/sd)'; then
                echo "Blocked: potentially destructive command" >&2
                exit 2
              fi
            '';
          }
        ];
        # After file edits, run linters if available
        PostToolUse = [
          {
            matcher = "Write|Edit|MultiEdit";
            command = ''
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
          }
        ];
        # Notify when Claude needs input
        Notification = [
          {
            command = "echo '🔔 Claude needs your input' >&2";
          }
        ];
        # Task completion notification
        Stop = [
          {
            command = ''
              # macOS notification
              if command -v osascript &>/dev/null; then
                osascript -e 'display notification "Task completed" with title "Claude Code"'
              # Linux notification (notify-send)
              elif command -v notify-send &>/dev/null; then
                notify-send "Claude Code" "Task completed"
              fi
            '';
          }
        ];
      };
    };
  };
}
