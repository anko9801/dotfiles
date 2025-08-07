#!/usr/bin/env bash
# DNF package provider

# Setup DNF
dnf_setup() {
    info "Updating DNF..."
    sudo dnf update -y
}

# Install DNF packages
dnf_install() {
    local packages=("$@")
    
    local pkgs_to_install=()
    for pkg in "${packages[@]}"; do
        if ! rpm -q "${pkg#@}" &>/dev/null 2>&1; then
            pkgs_to_install+=("$pkg")
        fi
    done
    
    if [[ ${#pkgs_to_install[@]} -gt 0 ]]; then
        info "Installing DNF packages..."
        sudo dnf install -y "${pkgs_to_install[@]}"
    else
        info "All DNF packages already installed"
    fi
}

# Check DNF packages
dnf_check() {
    local packages=("$@")
    local all_installed=true
    
    for pkg in "${packages[@]}"; do
        if ! rpm -q "${pkg#@}" &>/dev/null 2>&1; then
            error "Missing DNF package: $pkg"
            all_installed=false
        fi
    done
    
    [[ "$all_installed" == "true" ]]
}

# List DNF packages
dnf_list() {
    echo -e "${GREEN}dnf:${NC}"
    for pkg in "$@"; do
        echo "  - $pkg"
    done
}

# Cleanup DNF packages
dnf_cleanup() {
    local expected_packages=("$@")
    local installed=$(dnf history userinstalled | tail -n +2)
    
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
        sudo dnf remove -y "${pkgs_to_remove[@]}"
    fi
}

# Dump DNF packages
dnf_dump() {
    echo "    dnf:"
    # List user installed packages
    dnf history userinstalled | tail -n +2 | sort | sed 's/^/      - /'
}