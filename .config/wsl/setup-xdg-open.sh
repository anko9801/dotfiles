#!/usr/bin/env bash
# Setup xdg-open to use Windows browser in WSL

# Check if running in WSL
if [[ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
    echo "Not running in WSL, skipping xdg-open setup"
    exit 0
fi

echo "Setting up xdg-open for WSL..."

# Create applications directory
mkdir -p ~/.local/share/applications

# Create desktop entry file if it doesn't exist
if [[ ! -f ~/.local/share/applications/file-protocol-handler.desktop ]]; then
    cat > ~/.local/share/applications/file-protocol-handler.desktop << 'EOF'
[Desktop Entry]
Type=Application
Version=1.0
Name=File Protocol Handler
NoDisplay=true
Exec=rundll32.exe url.dll,FileProtocolHandler
EOF
fi

# Set as default web browser
xdg-settings set default-web-browser file-protocol-handler.desktop

echo "xdg-open has been configured to use Windows default browser"