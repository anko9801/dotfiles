#!/usr/bin/env bash
# Script provider for custom installation scripts

# Install via scripts
script_install() {
    local distro="$1"
    local count=$(yq eval ".packages.${distro}.script | length" "$PACKAGES_FILE" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${distro}.script[$i].name" "$PACKAGES_FILE")
        local script=$(yq eval ".packages.${distro}.script[$i].script" "$PACKAGES_FILE")
        
        # Skip if already installed
        if command -v "$name" &>/dev/null; then
            continue
        fi
        
        info "Installing $name via script..."
        eval "$script"
    done
}

# Check script packages
script_check() {
    local distro="$1"
    local all_installed=true
    local count=$(yq eval ".packages.${distro}.script | length" "$PACKAGES_FILE" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${distro}.script[$i].name" "$PACKAGES_FILE")
        if ! command -v "$name" &>/dev/null; then
            error "Missing script package: $name"
            all_installed=false
        fi
    done
    
    [[ "$all_installed" == "true" ]]
}

# List script packages
script_list() {
    local distro="$1"
    
    echo -e "\n${GREEN}script:${NC}"
    local count=$(yq eval ".packages.${distro}.script | length" "$PACKAGES_FILE" 2>/dev/null || echo "0")
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${distro}.script[$i].name" "$PACKAGES_FILE" 2>/dev/null || echo "")
        [[ -n "$name" && "$name" != "null" ]] && echo "  - $name"
    done
}

# Scripts don't support cleanup
script_cleanup() {
    warning "Script cleanup not implemented"
}

# Scripts don't support dump
script_dump() {
    echo "    # Script installations cannot be automatically dumped"
}