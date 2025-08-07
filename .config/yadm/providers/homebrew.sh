#!/usr/bin/env bash
# Homebrew package provider

# Setup Homebrew
homebrew_setup() {
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ -d "/opt/homebrew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    # Update Homebrew
    brew update
}

# Install Homebrew taps
homebrew_tap_install() {
    local taps=("$@")
    
    if ! command -v brew &>/dev/null; then
        error "Homebrew is not installed"
        return 1
    fi
    
    for tap in "${taps[@]}"; do
        if ! brew tap | grep -q "^$tap\$"; then
            info "Tapping $tap..."
            brew tap "$tap"
        fi
    done
}

# Install Homebrew formulae
homebrew_install() {
    local packages=("$@")
    
    if ! command -v brew &>/dev/null; then
        error "Homebrew is not installed"
        return 1
    fi
    
    local pkgs_to_install=()
    for pkg in "${packages[@]}"; do
        # Check if already installed
        if ! brew list --formula "$pkg" &>/dev/null 2>&1; then
            pkgs_to_install+=("$pkg")
        fi
    done
    
    if [[ ${#pkgs_to_install[@]} -gt 0 ]]; then
        info "Installing ${#pkgs_to_install[@]} formulae..."
        brew install --formula "${pkgs_to_install[@]}"
    else
        info "All formulae already installed"
    fi
}

# Install Homebrew casks
homebrew_cask_install() {
    local casks=("$@")
    
    if ! command -v brew &>/dev/null; then
        error "Homebrew is not installed"
        return 1
    fi
    
    local casks_to_install=()
    for cask in "${casks[@]}"; do
        # Check if already installed
        if ! brew list --cask "$cask" &>/dev/null 2>&1; then
            casks_to_install+=("$cask")
        fi
    done
    
    if [[ ${#casks_to_install[@]} -gt 0 ]]; then
        info "Installing ${#casks_to_install[@]} casks..."
        brew install --cask "${casks_to_install[@]}"
    else
        info "All casks already installed"
    fi
}

# Check Homebrew packages
homebrew_check() {
    local packages=("$@")
    local all_installed=true
    
    for pkg in "${packages[@]}"; do
        if ! brew list --formula "$pkg" &>/dev/null 2>&1; then
            error "Missing formula: $pkg"
            all_installed=false
        fi
    done
    
    [[ "$all_installed" == "true" ]]
}

homebrew_cask_check() {
    local casks=("$@")
    local all_installed=true
    
    for cask in "${casks[@]}"; do
        if ! brew list --cask "$cask" &>/dev/null 2>&1; then
            error "Missing cask: $cask"
            all_installed=false
        fi
    done
    
    [[ "$all_installed" == "true" ]]
}

# List Homebrew packages (packages are passed as arguments)
homebrew_list() {
    echo -e "${GREEN}homebrew:${NC}"
    for pkg in "$@"; do
        echo "  - $pkg"
    done
}

homebrew_cask_list() {
    echo -e "${GREEN}homebrew_cask:${NC}"
    for cask in "$@"; do
        echo "  - $cask"
    done
}

# Cleanup Homebrew packages
homebrew_cleanup() {
    local expected_formulae=("$@")
    local installed_formulae=$(brew list --formula)
    
    local formulae_to_remove=()
    while IFS= read -r formula; do
        local found=false
        for expected in "${expected_formulae[@]}"; do
            [[ "$formula" == "$expected" ]] && found=true && break
        done
        [[ "$found" == "false" ]] && formulae_to_remove+=("$formula")
    done <<< "$installed_formulae"
    
    if [[ ${#formulae_to_remove[@]} -gt 0 ]]; then
        info "Removing ${#formulae_to_remove[@]} formulae..."
        brew uninstall --formula "${formulae_to_remove[@]}"
    fi
}

homebrew_cask_cleanup() {
    local expected_casks=("$@")
    local installed_casks=$(brew list --cask)
    
    local casks_to_remove=()
    while IFS= read -r cask; do
        local found=false
        for expected in "${expected_casks[@]}"; do
            [[ "$cask" == "$expected" ]] && found=true && break
        done
        [[ "$found" == "false" ]] && casks_to_remove+=("$cask")
    done <<< "$installed_casks"
    
    if [[ ${#casks_to_remove[@]} -gt 0 ]]; then
        info "Removing ${#casks_to_remove[@]} casks..."
        brew uninstall --cask "${casks_to_remove[@]}"
    fi
}

# Dump Homebrew packages
homebrew_dump() {
    # Dump taps
    local taps=$(brew tap)
    if [[ -n "$taps" ]]; then
        echo "    homebrew_tap:"
        echo "$taps" | sed 's/^/      - /'
    fi
    
    # Dump formulae
    local formulae=$(brew list --formula)
    if [[ -n "$formulae" ]]; then
        echo "    homebrew:"
        echo "$formulae" | sed 's/^/      - /'
    fi
    
    # Dump casks
    local casks=$(brew list --cask)
    if [[ -n "$casks" ]]; then
        echo "    homebrew_cask:"
        echo "$casks" | sed 's/^/      - /'
    fi
}