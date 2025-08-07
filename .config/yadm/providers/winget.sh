#!/usr/bin/env bash
# Winget package provider

# Setup package managers
winget_setup() {
    if ! command -v winget &>/dev/null; then
        warning "Winget not found. Please install Windows Package Manager"
    fi
}

scoop_setup() {
    if ! command -v scoop &>/dev/null; then
        info "Installing Scoop..."
        powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
        powershell -Command "irm get.scoop.sh | iex"
    fi
}

# Install Winget packages
winget_install() {
    local packages=("$@")
    
    for pkg in "${packages[@]}"; do
        if ! winget list --id "$pkg" &>/dev/null; then
            info "Installing $pkg via winget..."
            winget install --id "$pkg" --accept-package-agreements --accept-source-agreements
        fi
    done
}

# Check Winget packages
winget_check() {
    local packages=("$@")
    local all_installed=true
    
    for pkg in "${packages[@]}"; do
        if ! winget list --id "$pkg" &>/dev/null; then
            error "Missing Winget package: $pkg"
            all_installed=false
        fi
    done
    
    [[ "$all_installed" == "true" ]]
}

# List Winget packages
winget_list() {
    echo -e "${GREEN}winget:${NC}"
    for pkg in "$@"; do
        echo "  - $pkg"
    done
}

# Cleanup not implemented for Winget
winget_cleanup() {
    warning "Winget cleanup not implemented"
}

# Dump Winget packages
winget_dump() {
    echo "    winget:"
    winget list | tail -n +5 | awk '{print $1}' | sort | sed 's/^/      - /'
}

# Install Scoop packages
scoop_install() {
    local packages=("$@")
    
    for pkg in "${packages[@]}"; do
        if ! scoop list "$pkg" &>/dev/null; then
            info "Installing $pkg via scoop..."
            scoop install "$pkg"
        fi
    done
}

# Check Scoop packages
scoop_check() {
    local packages=("$@")
    local all_installed=true
    
    for pkg in "${packages[@]}"; do
        if ! scoop list "$pkg" &>/dev/null; then
            error "Missing Scoop package: $pkg"
            all_installed=false
        fi
    done
    
    [[ "$all_installed" == "true" ]]
}

# List Scoop packages
scoop_list() {
    echo -e "${GREEN}scoop:${NC}"
    for pkg in "$@"; do
        echo "  - $pkg"
    done
}

# Dump Scoop packages
scoop_dump() {
    if command -v scoop &>/dev/null; then
        echo "    scoop:"
        scoop list | tail -n +3 | awk '{print $1}' | sort | sed 's/^/      - /'
    fi
}