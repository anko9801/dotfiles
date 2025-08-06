#!/usr/bin/env bash
# Generic package installer that reads from packages.yaml

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/packages.yaml"

# Detect OS and distribution
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "${ID,,}" in
            ubuntu|debian) echo "debian" ;;
            arch|manjaro) echo "arch" ;;
            fedora) echo "fedora" ;;
            *) echo "linux" ;;
        esac
    else
        echo "linux"
    fi
}

# Install packages from YAML
install_packages() {
    local platform="$1"
    local yaml_file="$2"
    
    # Check if yq is available
    if ! command -v yq &>/dev/null; then
        error "yq is required to parse packages.yaml"
        info "Installing yq..."
        
        case "$platform" in
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
            *)
                error "Please install yq manually"
                return 1
                ;;
        esac
    fi
    
    # Check if platform exists in packages
    local has_platform=$(yq eval ".packages.${platform} // \"none\"" "$yaml_file")
    if [[ "$has_platform" == "none" || "$has_platform" == "null" ]]; then
        warning "No packages defined for platform: $platform"
        return 0
    fi
    
    # Get all package managers for this platform
    local package_managers=$(yq eval ".packages.${platform} | keys | .[]" "$yaml_file" 2>/dev/null || true)
    
    # Install packages for each package manager
    while IFS= read -r pm; do
        [[ -z "$pm" ]] && continue
        install_by_package_manager "$platform" "$pm" "$yaml_file"
    done <<< "$package_managers"
}

# Install packages using specific package manager
install_by_package_manager() {
    local platform="$1"
    local pm="$2"
    local yaml_file="$3"
    
    info "Installing packages via $pm..."
    
    case "$pm" in
        homebrew|homebrew_cask)
            # Homebrewパッケージは.config/yadm/Brewfileで管理
            warning "Homebrew packages are managed by Brewfile"
            warning "Run 'brew bundle --file=$HOME/.config/yadm/Brewfile' to install"
            ;;
        apt)
            install_apt_packages "$platform" "$yaml_file"
            ;;
        pacman)
            install_pacman_packages "$platform" "$yaml_file"
            ;;
        dnf)
            install_dnf_packages "$platform" "$yaml_file"
            ;;
        winget)
            install_winget_packages "$platform" "$yaml_file"
            ;;
        scoop)
            install_scoop_packages "$platform" "$yaml_file"
            ;;
        aur)
            install_aur_packages "$platform" "$yaml_file"
            ;;
        cargo)
            install_cargo_packages "$platform" "$yaml_file"
            ;;
        git_clone)
            install_git_clone_packages "$platform" "$yaml_file"
            ;;
        apt_repository)
            install_apt_repositories "$platform" "$yaml_file"
            ;;
        rpm_repository)
            install_rpm_repositories "$platform" "$yaml_file"
            ;;
        copr)
            install_copr_packages "$platform" "$yaml_file"
            ;;
        github_release)
            install_github_releases "$platform" "$yaml_file"
            ;;
        script)
            install_scripts "$platform" "$yaml_file"
            ;;
        powershell)
            install_powershell_scripts "$platform" "$yaml_file"
            ;;
    esac
}

# Package manager specific installation functions
# Homebrew packages are now managed via Brewfile

install_apt_packages() {
    local platform="$1"
    local yaml_file="$2"
    
    local packages=$(yq eval ".packages.${platform}.apt[]" "$yaml_file" 2>/dev/null || true)
    
    local pkgs_to_install=""
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        if ! dpkg -l "$pkg" &>/dev/null 2>&1; then
            pkgs_to_install="$pkgs_to_install $pkg"
        fi
    done <<< "$packages"
    
    [[ -n "$pkgs_to_install" ]] && sudo apt-get install -y $pkgs_to_install
}

install_pacman_packages() {
    local platform="$1"
    local yaml_file="$2"
    
    local packages=$(yq eval ".packages.${platform}.pacman[]" "$yaml_file" 2>/dev/null || true)
    
    local pkgs_to_install=""
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        if ! pacman -Q "$pkg" &>/dev/null 2>&1; then
            pkgs_to_install="$pkgs_to_install $pkg"
        fi
    done <<< "$packages"
    
    [[ -n "$pkgs_to_install" ]] && sudo pacman -S --needed --noconfirm $pkgs_to_install
}

install_dnf_packages() {
    local platform="$1"
    local yaml_file="$2"
    
    local packages=$(yq eval ".packages.${platform}.dnf[]" "$yaml_file" 2>/dev/null || true)
    
    local pkgs_to_install=""
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        if ! rpm -q "${pkg#@}" &>/dev/null 2>&1; then
            pkgs_to_install="$pkgs_to_install $pkg"
        fi
    done <<< "$packages"
    
    [[ -n "$pkgs_to_install" ]] && sudo dnf install -y $pkgs_to_install
}

install_winget_packages() {
    local platform="$1"
    local yaml_file="$2"
    
    local packages=$(yq eval ".packages.${platform}.winget[]" "$yaml_file" 2>/dev/null || true)
    
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        winget list --id "$pkg" &>/dev/null || winget install --id "$pkg" --accept-package-agreements --accept-source-agreements
    done <<< "$packages"
}

install_scoop_packages() {
    local platform="$1"
    local yaml_file="$2"
    
    local packages=$(yq eval ".packages.${platform}.scoop[]" "$yaml_file" 2>/dev/null || true)
    
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        scoop list "$pkg" &>/dev/null || scoop install "$pkg"
    done <<< "$packages"
}

install_aur_packages() {
    local platform="$1"
    local yaml_file="$2"
    
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
    
    local packages=$(yq eval ".packages.${platform}.aur[]" "$yaml_file" 2>/dev/null || true)
    
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        "$aur_helper" -Q "$pkg" &>/dev/null || "$aur_helper" -S --needed --noconfirm "$pkg"
    done <<< "$packages"
}

install_cargo_packages() {
    local platform="$1"
    local yaml_file="$2"
    
    if ! command -v cargo &>/dev/null; then
        warning "Cargo not found, skipping cargo packages"
        return
    fi
    
    local packages=$(yq eval ".packages.${platform}.cargo[]" "$yaml_file" 2>/dev/null || true)
    
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "null" ]] && continue
        command -v "$pkg" &>/dev/null || cargo install "$pkg"
    done <<< "$packages"
}

install_git_clone_packages() {
    local platform="$1"
    local yaml_file="$2"
    
    local count=$(yq eval ".packages.${platform}.git_clone | length" "$yaml_file" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${platform}.git_clone[$i].name" "$yaml_file")
        local repo=$(yq eval ".packages.${platform}.git_clone[$i].repo" "$yaml_file")
        local dest=$(eval echo $(yq eval ".packages.${platform}.git_clone[$i].dest" "$yaml_file"))
        
        if [[ ! -d "$dest" ]]; then
            info "Cloning $name..."
            git clone "$repo" "$dest"
        fi
    done
}

install_apt_repositories() {
    local platform="$1"
    local yaml_file="$2"
    
    local count=$(yq eval ".packages.${platform}.apt_repository | length" "$yaml_file" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${platform}.apt_repository[$i].name" "$yaml_file")
        local key=$(yq eval ".packages.${platform}.apt_repository[$i].key" "$yaml_file")
        local repo=$(yq eval ".packages.${platform}.apt_repository[$i].repo" "$yaml_file")
        local package=$(yq eval ".packages.${platform}.apt_repository[$i].package" "$yaml_file")
        local setup=$(yq eval ".packages.${platform}.apt_repository[$i].setup // \"\"" "$yaml_file")
        
        # Add repository if package not installed
        if ! dpkg -l "$package" &>/dev/null 2>&1; then
            info "Adding APT repository for $name..."
            
            # Add GPG key
            local keyring_path="/usr/share/keyrings/${name}-archive-keyring.gpg"
            curl -fsSL "$key" | sudo gpg --dearmor -o "$keyring_path"
            
            # Add repository (evaluate shell expansions)
            eval "echo \"$repo\"" | sudo tee "/etc/apt/sources.list.d/${name}.list" > /dev/null
            
            # Run extra setup if needed
            if [[ -n "$setup" && "$setup" != "null" ]]; then
                eval "$setup"
            fi
            
            sudo apt update
            sudo apt install -y "$package"
        fi
    done
}

install_rpm_repositories() {
    local platform="$1"
    local yaml_file="$2"
    
    local count=$(yq eval ".packages.${platform}.rpm_repository | length" "$yaml_file" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${platform}.rpm_repository[$i].name" "$yaml_file")
        local key=$(yq eval ".packages.${platform}.rpm_repository[$i].key" "$yaml_file")
        local repo=$(yq eval ".packages.${platform}.rpm_repository[$i].repo" "$yaml_file")
        local package=$(yq eval ".packages.${platform}.rpm_repository[$i].package" "$yaml_file")
        
        if ! rpm -q "$package" &>/dev/null 2>&1; then
            info "Adding RPM repository for $name..."
            
            # Import GPG key
            sudo rpm --import "$key"
            
            # Add repository
            echo "$repo" | sudo tee "/etc/yum.repos.d/${name}.repo" > /dev/null
            
            sudo dnf install -y "$package"
        fi
    done
}

install_copr_packages() {
    local platform="$1"
    local yaml_file="$2"
    
    local count=$(yq eval ".packages.${platform}.copr | length" "$yaml_file" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local repo=$(yq eval ".packages.${platform}.copr[$i].repo" "$yaml_file")
        local package=$(yq eval ".packages.${platform}.copr[$i].package" "$yaml_file")
        
        if ! command -v "$package" &>/dev/null; then
            sudo dnf copr enable -y "$repo"
            sudo dnf install -y "$package"
        fi
    done
}

install_github_releases() {
    local platform="$1"
    local yaml_file="$2"
    
    local count=$(yq eval ".packages.${platform}.github_release | length" "$yaml_file" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${platform}.github_release[$i].name" "$yaml_file")
        local repo=$(yq eval ".packages.${platform}.github_release[$i].repo" "$yaml_file")
        local file=$(yq eval ".packages.${platform}.github_release[$i].file" "$yaml_file")
        local type=$(yq eval ".packages.${platform}.github_release[$i].type" "$yaml_file")
        
        # Skip if already installed
        command -v "$name" &>/dev/null && continue
        
        info "Installing $name from GitHub..."
        
        # Get latest version (tag_name might start with 'v' or not)
        local tag_name=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        local version=$(echo "$tag_name" | sed 's/^v//')
        local url=$(echo "$file" | sed "s/VERSION/$version/g")
        
        local tmp_dir=$(mktemp -d)
        cd "$tmp_dir"
        
        case "$type" in
            deb)
                # Use the actual tag name for the download URL
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fLO "$download_url" || { error "Failed to download $name from $download_url"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                sudo dpkg -i *.deb || sudo apt-get install -f -y
                ;;
            rpm)
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fLO "$download_url" || { error "Failed to download $name from $download_url"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                sudo rpm -i *.rpm
                ;;
            tar)
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fL "$download_url" | tar -xz || { error "Failed to download $name from $download_url"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                find . -type f -executable -name "$name" -exec sudo mv {} /usr/local/bin/ \;
                ;;
            zip)
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fLO "$download_url" || { error "Failed to download $name from $download_url"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                unzip -j -o *.zip
                find . -type f -name "$name" -exec sudo mv {} /usr/local/bin/ \;
                ;;
            binary)
                local download_url="https://github.com/$repo/releases/download/$tag_name/$url"
                curl -fL "$download_url" -o "$name" || { error "Failed to download $name from $download_url"; cd - >/dev/null; rm -rf "$tmp_dir"; continue; }
                chmod +x "$name"
                sudo mv "$name" /usr/local/bin/
                ;;
        esac
        
        cd - >/dev/null
        rm -rf "$tmp_dir"
    done
}

install_scripts() {
    local platform="$1"
    local yaml_file="$2"
    
    local count=$(yq eval ".packages.${platform}.script | length" "$yaml_file" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${platform}.script[$i].name" "$yaml_file")
        local script=$(yq eval ".packages.${platform}.script[$i].script" "$yaml_file")
        
        # Skip if already installed (except for git clone scripts)
        if [[ "$name" != "tpm" ]] && command -v "$name" &>/dev/null; then
            continue
        fi
        
        # Skip tpm if already installed
        if [[ "$name" == "tpm" ]] && [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
            continue
        fi
        
        info "Installing $name via script..."
        eval "$script"
    done
}

install_powershell_scripts() {
    local platform="$1"
    local yaml_file="$2"
    
    local count=$(yq eval ".packages.${platform}.powershell | length" "$yaml_file" 2>/dev/null || echo "0")
    
    for i in $(seq 0 $((count - 1))); do
        local name=$(yq eval ".packages.${platform}.powershell[$i].name" "$yaml_file")
        local script=$(yq eval ".packages.${platform}.powershell[$i].script" "$yaml_file")
        
        # Skip if already installed
        command -v "$name" &>/dev/null && continue
        
        info "Installing $name via PowerShell..."
        powershell -Command "$script"
    done
}

# Run post-install commands
run_post_install() {
    local yaml_file="$1"
    
    info "Running post-install configurations..."
    
    # Get all post-install packages
    local packages=$(yq eval '.post_install | keys | .[]' "$yaml_file" 2>/dev/null || true)
    
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        
        # Check if package is installed
        if ! command -v "$pkg" &>/dev/null && [[ "$pkg" != "1password-cli" ]]; then
            continue
        fi
        
        # Special case for 1password-cli
        if [[ "$pkg" == "1password-cli" ]] && ! command -v op &>/dev/null; then
            continue
        fi
        
        info "Running post-install for $pkg..."
        
        # Run post-install commands (always array format)
        local commands=$(yq eval ".post_install.${pkg}[]" "$yaml_file" 2>/dev/null || true)
        
        while IFS= read -r cmd; do
            [[ -z "$cmd" || "$cmd" == "null" ]] && continue
            eval "$cmd"
        done <<< "$commands"
    done <<< "$packages"
}

# Main function
main() {
    local platform=$(detect_platform)
    info "Detected platform: $platform"
    
    # Check if packages.yaml exists
    if [[ ! -f "$PACKAGES_FILE" ]]; then
        error "packages.yaml not found at $PACKAGES_FILE"
        exit 1
    fi
    
    # Install packages
    install_packages "$platform" "$PACKAGES_FILE"
    
    # Run post-install
    run_post_install "$PACKAGES_FILE"
    
    success "Installation complete!"
}

# Only run main if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Source logging functions from parent install script if available
    if [[ -z "$(type -t info)" ]]; then
        info() { echo "===> $1"; }
        success() { echo "✓ $1"; }
        error() { echo "✗ $1" >&2; }
        warning() { echo "! $1"; }
    fi
    
    main "$@"
fi