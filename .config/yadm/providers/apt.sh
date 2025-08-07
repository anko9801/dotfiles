#!/usr/bin/env bash
# APT package provider

# Setup APT
apt_setup() {
    info "Updating APT package lists..."
    sudo apt-get update || true
}

# Install APT packages
apt_install() {
    local packages=("$@")
    
    local pkgs_to_install=()
    for pkg in "${packages[@]}"; do
        if ! dpkg -l "$pkg" &>/dev/null 2>&1; then
            pkgs_to_install+=("$pkg")
        fi
    done
    
    if [[ ${#pkgs_to_install[@]} -gt 0 ]]; then
        info "Installing APT packages..."
        sudo apt-get install -y "${pkgs_to_install[@]}"
    else
        info "All APT packages already installed"
    fi
}

# Install APT repositories
apt_repository_install() {
    local distro="$1"
    local count=$(yq eval ".packages.${distro}.apt_repository | length" "$PACKAGES_FILE" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${distro}.apt_repository[$i].name" "$PACKAGES_FILE")
        local key=$(yq eval ".packages.${distro}.apt_repository[$i].key" "$PACKAGES_FILE")
        local repo=$(yq eval ".packages.${distro}.apt_repository[$i].repo" "$PACKAGES_FILE")
        local package=$(yq eval ".packages.${distro}.apt_repository[$i].package" "$PACKAGES_FILE")
        local setup=$(yq eval ".packages.${distro}.apt_repository[$i].setup" "$PACKAGES_FILE" 2>/dev/null || echo "")
        
        info "Setting up $name repository..."
        
        # Run setup commands if provided
        if [[ -n "$setup" && "$setup" != "null" ]]; then
            eval "$setup"
        fi
        
        # Download and add GPG key
        curl -fsSL "$key" | sudo gpg --dearmor -o "/usr/share/keyrings/${name}-archive-keyring.gpg"
        
        # Add repository
        echo "$repo" | sudo tee "/etc/apt/sources.list.d/${name}.list" > /dev/null
        
        # Update and install package
        sudo apt-get update
        sudo apt-get install -y "$package"
    done
}

# Check APT packages
apt_check() {
    local distro="$1"
    local all_installed=true
    
    local packages=$(yq eval ".packages.${distro}.apt[]" "$PACKAGES_FILE" 2>/dev/null || true)
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        if ! dpkg -l "$pkg" &>/dev/null 2>&1; then
            error "Missing APT package: $pkg"
            all_installed=false
        fi
    done <<< "$packages"
    
    [[ "$all_installed" == "true" ]]
}

# List APT packages
apt_list() {
    local distro="$1"
    
    echo -e "\n${GREEN}apt:${NC}"
    yq eval ".packages.${distro}.apt[]" "$PACKAGES_FILE" 2>/dev/null | sed 's/^/  - /' || echo "  (none)"
}

apt_repository_list() {
    local distro="$1"
    
    echo -e "\n${GREEN}apt_repository:${NC}"
    local count=$(yq eval ".packages.${distro}.apt_repository | length" "$PACKAGES_FILE" 2>/dev/null || echo "0")
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${distro}.apt_repository[$i].name" "$PACKAGES_FILE" 2>/dev/null || echo "")
        [[ -n "$name" && "$name" != "null" ]] && echo "  - $name"
    done
}

# Cleanup APT packages
apt_cleanup() {
    local distro="$1"
    
    local installed=$(dpkg-query -W -f='${Status} ${Package}\n' | grep "^install ok installed" | awk '{print $4}')
    local expected=$(yq eval ".packages.${distro}.apt[]" "$PACKAGES_FILE" 2>/dev/null || true)
    
    local pkgs_to_remove=()
    while IFS= read -r pkg; do
        if ! echo "$expected" | grep -q "^$pkg\$"; then
            pkgs_to_remove+=("$pkg")
        fi
    done <<< "$installed"
    
    if [[ ${#pkgs_to_remove[@]} -gt 0 ]]; then
        info "Removing ${#pkgs_to_remove[@]} packages..."
        sudo apt-get remove --purge -y "${pkgs_to_remove[@]}"
        sudo apt-get autoremove -y
    fi
}

# Dump APT packages
apt_dump() {
    echo "    apt:"
    # List manually installed packages (not dependencies)
    dpkg-query -W -f='${Status} ${Package}\n' | grep "^install ok installed" | grep -v "deinstall" | awk '{print $4}' | sort | sed 's/^/      - /'
}