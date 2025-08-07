#!/usr/bin/env bash
# Cargo package provider

# Install Cargo packages
cargo_install() {
    local distro="$1"
    
    if ! command -v cargo &>/dev/null; then
        warning "Cargo not found, skipping cargo packages"
        return
    fi
    
    local packages=$(yq eval ".packages.${distro}.cargo[]" "$PACKAGES_FILE" 2>/dev/null || true)
    
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        if ! command -v "$pkg" &>/dev/null; then
            info "Installing $pkg via cargo..."
            cargo install "$pkg"
        fi
    done <<< "$packages"
}

# Check Cargo packages
cargo_check() {
    local distro="$1"
    local all_installed=true
    
    local packages=$(yq eval ".packages.${distro}.cargo[]" "$PACKAGES_FILE" 2>/dev/null || true)
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        if ! command -v "$pkg" &>/dev/null; then
            error "Missing cargo package: $pkg"
            all_installed=false
        fi
    done <<< "$packages"
    
    [[ "$all_installed" == "true" ]]
}

# List Cargo packages
cargo_list() {
    local distro="$1"
    
    echo -e "\n${GREEN}cargo:${NC}"
    yq eval ".packages.${distro}.cargo[]" "$PACKAGES_FILE" 2>/dev/null | sed 's/^/  - /' || echo "  (none)"
}

# Cleanup Cargo packages
cargo_cleanup() {
    warning "Cargo cleanup not implemented"
}

# Dump Cargo packages
cargo_dump() {
    echo "    cargo:"
    cargo install --list | grep -E "^[a-zA-Z0-9_-]+ v" | awk '{print $1}' | sort | sed 's/^/      - /'
}