#!/usr/bin/env bash
# WSL2 specific configurations

# Check if running on WSL2
if [[ ! $(uname -r) =~ microsoft ]]; then
    return 0
fi

# WSL2 environment variables
export BROWSER="wslview"
export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2)

# 1Password SSH Agent setup
setup_1password_ssh_agent() {
    # Set SSH auth socket path
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
    
    # Check if npiperelay is available
    if ! command -v npiperelay.exe >/dev/null 2>&1; then
        echo "⚠️  npiperelay.exe not found!"
        echo "   Please install npiperelay in Windows and ensure it's in PATH"
        echo "   https://github.com/jstarks/npiperelay"
        return 1
    fi
    
    # Check if socket is already running
    if ! ss -a | grep -q "$SSH_AUTH_SOCK" >/dev/null 2>&1; then
        # Remove old socket if exists
        if [[ -e "$SSH_AUTH_SOCK" ]]; then
            rm -f "$SSH_AUTH_SOCK"
        fi
        
        # Start SSH agent relay
        echo "🔑 Starting 1Password SSH agent relay..."
        (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
    fi
}

# WSL2 time sync fix
wsl2_fix_time() {
    echo "🕐 Syncing WSL2 time..."
    if command -v ntpdate >/dev/null 2>&1; then
        sudo ntpdate ntp.nict.jp || sudo ntpdate time.google.com
    elif command -v hwclock >/dev/null 2>&1; then
        sudo hwclock -s
    else
        echo "❌ No time sync tool found (install ntpdate or util-linux)"
        return 1
    fi
    echo "✅ Time synced!"
}

# WSL2 memory reclaim
wsl2_compact_memory() {
    echo "🧹 Compacting WSL2 memory..."
    echo 1 | sudo tee /proc/sys/vm/drop_caches >/dev/null
    echo "✅ Memory compacted!"
}

# Open Windows Explorer from current directory
explorer() {
    explorer.exe "${1:-.}"
}

# Copy to Windows clipboard
if command -v clip.exe >/dev/null 2>&1; then
    alias pbcopy='clip.exe'
fi

# Paste from Windows clipboard
if command -v powershell.exe >/dev/null 2>&1; then
    alias pbpaste='powershell.exe -command "Get-Clipboard" | tr -d "\r"'
fi

# Docker Desktop integration
if [[ -S "/var/run/docker.sock" ]]; then
    export DOCKER_HOST="unix:///var/run/docker.sock"
fi

# X11 forwarding for GUI apps (if VcXsrv or similar is running)
if command -v vcxsrv.exe >/dev/null 2>&1 || command -v xming.exe >/dev/null 2>&1; then
    export DISPLAY="${WSL_HOST}:0"
fi

# Initialize 1Password SSH agent
setup_1password_ssh_agent

# Add WSL2 utilities to PATH
export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"