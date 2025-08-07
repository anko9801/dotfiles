#!/usr/bin/env bash
# Common functions and variables

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HOME="${HOME:-$(eval echo ~)}"
readonly PACKAGES_FILE="${PACKAGES_FILE:-$HOME/.config/packages.yaml}"
readonly EXIT_SUCCESS=0 EXIT_ERROR=1

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Output functions
info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; }
warning() { echo -e "${YELLOW}!${NC} $1"; }

# Detect platform and distro
detect_platform() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
                detect_linux_distro
            else
                detect_linux_distro
            fi
            ;;
        MINGW*|CYGWIN*|MSYS*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

detect_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "${ID,,}" in
            ubuntu|debian)
                echo "debian"
                ;;
            arch|manjaro)
                echo "arch"
                ;;
            fedora)
                echo "fedora"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# Check and install yq if needed
ensure_yq() {
    if ! command -v yq &>/dev/null; then
        error "yq is required"
        info "Installing yq..."
        
        local distro=$(detect_platform)
        case "$distro" in
            macos)
                brew install yq
                ;;
            debian)
                sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
                sudo chmod +x /usr/local/bin/yq
                ;;
            arch)
                sudo pacman -S --needed --noconfirm yq
                ;;
            fedora)
                sudo dnf install -y yq
                ;;
            windows)
                scoop install yq || winget install --id MikeFarah.yq
                ;;
            *)
                error "Please install yq manually"
                exit 1
                ;;
        esac
    fi
}

# Run post-install hooks
run_post_install_hooks() {
    info "Running post-install hooks..."
    
    # Get all post-install sections
    local hooks=$(yq eval '.post_install | keys | .[]' "$PACKAGES_FILE" 2>/dev/null || true)
    
    while IFS= read -r hook; do
        [[ -z "$hook" || "$hook" == "null" ]] && continue
        
        # Check if the command exists
        if command -v "$hook" &>/dev/null || [[ -f "$HOME/.local/bin/$hook" ]]; then
            info "Running post-install for $hook..."
            
            local commands=$(yq eval ".post_install.${hook}[]" "$PACKAGES_FILE" 2>/dev/null || true)
            while IFS= read -r cmd; do
                [[ -z "$cmd" || "$cmd" == "null" ]] && continue
                bash -c "$cmd" || warning "Failed to execute: $cmd"
            done <<< "$commands"
        fi
    done <<< "$hooks"
}

# Load a provider if it exists
load_provider() {
    local provider="$1"
    local provider_file="${SCRIPT_DIR}/providers/${provider}.sh"
    
    if [[ -f "$provider_file" ]]; then
        source "$provider_file"
        return 0
    else
        return 1
    fi
}