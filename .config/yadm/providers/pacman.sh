#!/usr/bin/env bash
# Pacman package provider

# Setup Pacman
pacman_setup() {
    info "Updating Pacman database..."
    sudo pacman -Syu --noconfirm
}

# Install Pacman packages
pacman_install() {
    local packages=("$@")
    
    local pkgs_to_install=()
    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null 2>&1; then
            pkgs_to_install+=("$pkg")
        fi
    done
    
    if [[ ${#pkgs_to_install[@]} -gt 0 ]]; then
        info "Installing Pacman packages..."
        sudo pacman -Syu --needed --noconfirm "${pkgs_to_install[@]}"
    else
        info "All Pacman packages already installed"
    fi
}

# Install AUR packages
aur_install() {
    local packages=("$@")
    
    # Determine AUR helper
    local aur_helper=""
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        warning "No AUR helper found, skipping AUR packages"
        return
    fi
    
    for pkg in "${packages[@]}"; do
        if ! "$aur_helper" -Q "$pkg" &>/dev/null; then
            info "Installing $pkg from AUR..."
            "$aur_helper" -S --needed --noconfirm "$pkg"
        fi
    done
}

# Check Pacman packages
pacman_check() {
    local packages=("$@")
    local all_installed=true
    
    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null 2>&1; then
            error "Missing Pacman package: $pkg"
            all_installed=false
        fi
    done
    
    [[ "$all_installed" == "true" ]]
}

# Check AUR packages
aur_check() {
    local packages=("$@")
    local all_installed=true
    
    # Determine AUR helper
    local aur_helper=""
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        warning "No AUR helper found"
        return 1
    fi
    
    for pkg in "${packages[@]}"; do
        if ! "$aur_helper" -Q "$pkg" &>/dev/null; then
            error "Missing AUR package: $pkg"
            all_installed=false
        fi
    done
    
    [[ "$all_installed" == "true" ]]
}

# List Pacman packages
pacman_list() {
    echo -e "${GREEN}pacman:${NC}"
    for pkg in "$@"; do
        echo "  - $pkg"
    done
}

aur_list() {
    echo -e "${GREEN}aur:${NC}"
    for pkg in "$@"; do
        echo "  - $pkg"
    done
}

# Cleanup Pacman packages
pacman_cleanup() {
    local expected_packages=("$@")
    local installed=$(pacman -Qe | awk '{print $1}')
    
    local pkgs_to_remove=()
    while IFS= read -r pkg; do
        local found=false
        for expected in "${expected_packages[@]}"; do
            [[ "$pkg" == "$expected" ]] && found=true && break
        done
        [[ "$found" == "false" ]] && pkgs_to_remove+=("$pkg")
    done <<< "$installed"
    
    if [[ ${#pkgs_to_remove[@]} -gt 0 ]]; then
        info "Removing ${#pkgs_to_remove[@]} packages..."
        sudo pacman -Rns --noconfirm "${pkgs_to_remove[@]}"
    fi
}

# Dump Pacman packages
pacman_dump() {
    echo "    pacman:"
    # List explicitly installed packages
    pacman -Qe | awk '{print $1}' | sort | sed 's/^/      - /'
}