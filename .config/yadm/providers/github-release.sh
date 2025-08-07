#!/usr/bin/env bash
# GitHub Release provider

# Install packages from GitHub releases
github_release_install() {
    local distro="$1"
    local count=$(yq eval ".packages.${distro}.github_release | length" "$PACKAGES_FILE" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${distro}.github_release[$i].name" "$PACKAGES_FILE")
        local repo=$(yq eval ".packages.${distro}.github_release[$i].repo" "$PACKAGES_FILE")
        local file=$(yq eval ".packages.${distro}.github_release[$i].file" "$PACKAGES_FILE")
        local type=$(yq eval ".packages.${distro}.github_release[$i].type" "$PACKAGES_FILE")
        
        # Skip if already installed
        command -v "$name" &>/dev/null && continue
        
        info "Installing $name from GitHub..."
        
        # Get latest version with User-Agent header
        local api_response=$(curl -sSL -H "User-Agent: Mozilla/5.0" "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null)
        
        if [[ -z "$api_response" ]] || echo "$api_response" | grep -q '"message".*"rate limit"'; then
            warning "GitHub API rate limit or connection issue. Trying alternative method..."
            local tag_name=$(curl -sSL -H "User-Agent: Mozilla/5.0" "https://api.github.com/repos/$repo/tags" 2>/dev/null | grep -Po '"name": "\K[^"]*' | head -1)
        else
            local tag_name=$(echo "$api_response" | grep -Po '"tag_name": "\K[^"]*')
        fi
        
        if [[ -z "$tag_name" ]]; then
            error "Failed to get version for $name from GitHub API"
            continue
        fi
        
        local version=$(echo "$tag_name" | sed 's/^v//')
        local url=$(echo "$file" | sed "s/VERSION/$version/g")
        
        local tmp_dir=$(mktemp -d)
        cd "$tmp_dir"
        
        case "$type" in
            deb)
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fLO -H "User-Agent: Mozilla/5.0" "$download_url" || { error "Failed to download $name"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                sudo dpkg -i *.deb || sudo apt-get install -f -y
                ;;
            rpm)
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fLO -H "User-Agent: Mozilla/5.0" "$download_url" || { error "Failed to download $name"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                sudo rpm -i *.rpm
                ;;
            tar)
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fL -H "User-Agent: Mozilla/5.0" "$download_url" | tar -xz || { error "Failed to download $name"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                find . -type f -executable -name "$name" -exec mv {} "$HOME/.local/bin/" \; 2>/dev/null || \
                find . -type f -name "$name" -exec mv {} "$HOME/.local/bin/" \; 2>/dev/null || \
                find . -type f -executable -exec mv {} "$HOME/.local/bin/$name" \; 2>/dev/null
                chmod +x "$HOME/.local/bin/$name" 2>/dev/null || true
                ;;
            zip)
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fLO -H "User-Agent: Mozilla/5.0" "$download_url" || { error "Failed to download $name"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                unzip -j -o *.zip
                find . -type f -name "$name" -exec mv {} "$HOME/.local/bin/" \; 2>/dev/null || \
                find . -type f -executable -exec mv {} "$HOME/.local/bin/$name" \; 2>/dev/null
                chmod +x "$HOME/.local/bin/$name" 2>/dev/null || true
                ;;
            binary)
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fL -H "User-Agent: Mozilla/5.0" "$download_url" -o "$name" || { error "Failed to download $name"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                chmod +x "$name"
                mv "$name" "$HOME/.local/bin/"
                ;;
        esac
        
        cd - >/dev/null
        rm -rf "$tmp_dir"
        
        success "Installed $name"
    done
}

# Check GitHub release packages
github_release_check() {
    local distro="$1"
    local all_installed=true
    local count=$(yq eval ".packages.${distro}.github_release | length" "$PACKAGES_FILE" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${distro}.github_release[$i].name" "$PACKAGES_FILE")
        if ! command -v "$name" &>/dev/null; then
            error "Missing GitHub release package: $name"
            all_installed=false
        fi
    done
    
    [[ "$all_installed" == "true" ]]
}

# List GitHub release packages
github_release_list() {
    local distro="$1"
    
    echo -e "\n${GREEN}github_release:${NC}"
    local count=$(yq eval ".packages.${distro}.github_release | length" "$PACKAGES_FILE" 2>/dev/null || echo "0")
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${distro}.github_release[$i].name" "$PACKAGES_FILE" 2>/dev/null || echo "")
        [[ -n "$name" && "$name" != "null" ]] && echo "  - $name"
    done
}

# GitHub releases don't support cleanup
github_release_cleanup() {
    warning "GitHub release cleanup not implemented"
}

# GitHub releases don't support dump
github_release_dump() {
    echo "    # GitHub releases cannot be automatically dumped"
}