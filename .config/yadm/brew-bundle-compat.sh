#!/usr/bin/env bash
# Homebrew Bundle compatibility layer for packages.yaml

set -euo pipefail

# Configuration
readonly PACKAGES_FILE="${PACKAGES_FILE:-$HOME/.config/packages.yaml}"
readonly BREWFILE_BACKUP="$HOME/.config/yadm/Brewfile.backup"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; }
warning() { echo -e "${YELLOW}!${NC} $1"; }

# Check dependencies
check_dependencies() {
    if ! command -v yq &>/dev/null; then
        error "yq is required"
        info "Install with: brew install yq"
        exit 1
    fi
    
    if ! command -v brew &>/dev/null; then
        error "Homebrew is required"
        exit 1
    fi
}

# Simulate brew bundle command
brew_bundle() {
    local command="${1:-install}"
    
    case "$command" in
        install|"")
            bundle_install
            ;;
        check)
            bundle_check
            ;;
        list)
            bundle_list
            ;;
        cleanup)
            bundle_cleanup
            ;;
        dump)
            bundle_dump
            ;;
        *)
            error "Unknown command: $command"
            echo "Usage: $0 [install|check|list|cleanup|dump]"
            exit 1
            ;;
    esac
}

# Install all packages from packages.yaml
bundle_install() {
    info "Installing from packages.yaml..."
    
    # Install taps
    local taps=$(yq eval '.packages.macos.homebrew_tap[]' "$PACKAGES_FILE" 2>/dev/null || true)
    while IFS= read -r tap; do
        [[ -z "$tap" || "$tap" == "null" ]] && continue
        if ! brew tap | grep -q "^$tap\$"; then
            info "Tapping $tap..."
            brew tap "$tap"
        fi
    done <<< "$taps"
    
    # Install formulae
    local formulae=$(yq eval '.packages.macos.homebrew[]' "$PACKAGES_FILE" 2>/dev/null || true)
    local formulae_to_install=()
    while IFS= read -r formula; do
        [[ -z "$formula" || "$formula" == "null" ]] && continue
        if ! brew list --formula "$formula" &>/dev/null 2>&1; then
            formulae_to_install+=("$formula")
        fi
    done <<< "$formulae"
    
    if [[ ${#formulae_to_install[@]} -gt 0 ]]; then
        info "Installing ${#formulae_to_install[@]} formulae..."
        brew install --formula "${formulae_to_install[@]}"
    fi
    
    # Install casks
    local casks=$(yq eval '.packages.macos.homebrew_cask[]' "$PACKAGES_FILE" 2>/dev/null || true)
    local casks_to_install=()
    while IFS= read -r cask; do
        [[ -z "$cask" || "$cask" == "null" ]] && continue
        if ! brew list --cask "$cask" &>/dev/null 2>&1; then
            casks_to_install+=("$cask")
        fi
    done <<< "$casks"
    
    if [[ ${#casks_to_install[@]} -gt 0 ]]; then
        info "Installing ${#casks_to_install[@]} casks..."
        brew install --cask "${casks_to_install[@]}"
    fi
    
    success "Installation complete"
}

# Check if all packages are installed
bundle_check() {
    info "Checking packages..."
    local all_installed=true
    
    # Check formulae
    local formulae=$(yq eval '.packages.macos.homebrew[]' "$PACKAGES_FILE" 2>/dev/null || true)
    while IFS= read -r formula; do
        [[ -z "$formula" || "$formula" == "null" ]] && continue
        if ! brew list --formula "$formula" &>/dev/null 2>&1; then
            error "Missing formula: $formula"
            all_installed=false
        fi
    done <<< "$formulae"
    
    # Check casks
    local casks=$(yq eval '.packages.macos.homebrew_cask[]' "$PACKAGES_FILE" 2>/dev/null || true)
    while IFS= read -r cask; do
        [[ -z "$cask" || "$cask" == "null" ]] && continue
        if ! brew list --cask "$cask" &>/dev/null 2>&1; then
            error "Missing cask: $cask"
            all_installed=false
        fi
    done <<< "$casks"
    
    if [[ "$all_installed" == "true" ]]; then
        success "All packages are installed"
    else
        error "Some packages are missing"
        exit 1
    fi
}

# List all packages
bundle_list() {
    info "Packages defined in $PACKAGES_FILE:"
    
    echo -e "\n${GREEN}Taps:${NC}"
    yq eval '.packages.macos.homebrew_tap[]' "$PACKAGES_FILE" 2>/dev/null || echo "  (none)"
    
    echo -e "\n${GREEN}Formulae:${NC}"
    yq eval '.packages.macos.homebrew[]' "$PACKAGES_FILE" 2>/dev/null || echo "  (none)"
    
    echo -e "\n${GREEN}Casks:${NC}"
    yq eval '.packages.macos.homebrew_cask[]' "$PACKAGES_FILE" 2>/dev/null || echo "  (none)"
}

# Remove packages not in packages.yaml
bundle_cleanup() {
    warning "This will remove packages not defined in packages.yaml"
    read -rp "Continue? (y/N): " -n 1 && echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
    
    # Get installed packages
    local installed_formulae=$(brew list --formula)
    local installed_casks=$(brew list --cask)
    
    # Get expected packages
    local expected_formulae=$(yq eval '.packages.macos.homebrew[]' "$PACKAGES_FILE" 2>/dev/null || true)
    local expected_casks=$(yq eval '.packages.macos.homebrew_cask[]' "$PACKAGES_FILE" 2>/dev/null || true)
    
    # Find packages to remove
    local formulae_to_remove=()
    while IFS= read -r formula; do
        if ! echo "$expected_formulae" | grep -q "^$formula\$"; then
            formulae_to_remove+=("$formula")
        fi
    done <<< "$installed_formulae"
    
    local casks_to_remove=()
    while IFS= read -r cask; do
        if ! echo "$expected_casks" | grep -q "^$cask\$"; then
            casks_to_remove+=("$cask")
        fi
    done <<< "$installed_casks"
    
    # Remove packages
    if [[ ${#formulae_to_remove[@]} -gt 0 ]]; then
        info "Removing ${#formulae_to_remove[@]} formulae..."
        brew uninstall --formula "${formulae_to_remove[@]}"
    fi
    
    if [[ ${#casks_to_remove[@]} -gt 0 ]]; then
        info "Removing ${#casks_to_remove[@]} casks..."
        brew uninstall --cask "${casks_to_remove[@]}"
    fi
    
    success "Cleanup complete"
}

# Generate Brewfile from current installation
bundle_dump() {
    info "Generating Brewfile from current installation..."
    
    # Backup existing Brewfile if it exists
    if [[ -f "$HOME/.config/yadm/Brewfile" ]]; then
        cp "$HOME/.config/yadm/Brewfile" "$BREWFILE_BACKUP"
        info "Backed up existing Brewfile to $BREWFILE_BACKUP"
    fi
    
    # Generate new Brewfile
    brew bundle dump --file="$HOME/.config/yadm/Brewfile" --force
    success "Brewfile generated at $HOME/.config/yadm/Brewfile"
    
    info "To convert to packages.yaml format, run:"
    echo "  $0 convert"
}

# Main
main() {
    check_dependencies
    brew_bundle "$@"
}

main "$@"