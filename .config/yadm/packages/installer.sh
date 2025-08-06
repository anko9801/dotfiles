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

# Parse YAML and install packages
install_from_yaml() {
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
    
    # Get all package names
    local packages=$(yq eval '.packages | keys | .[]' "$yaml_file")
    
    # Install each package
    while IFS= read -r pkg; do
        install_package "$pkg" "$platform" "$yaml_file"
    done <<< "$packages"
}

# Install a single package based on platform
install_package() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    
    # Check if package has platform-specific installation
    local has_platform=$(yq eval ".packages.${package}.${platform} // \"none\"" "$yaml_file")
    local has_all=$(yq eval ".packages.${package}.all // \"none\"" "$yaml_file")
    local has_linux=$(yq eval ".packages.${package}.linux // \"none\"" "$yaml_file")
    
    # Try platform-specific first
    if [[ "$has_platform" != "none" && "$has_platform" != "null" ]]; then
        install_package_platform "$package" "$platform" "$yaml_file"
    # Try linux-wide installation for linux platforms
    elif [[ "$platform" != "macos" && "$platform" != "windows" && "$has_linux" != "none" && "$has_linux" != "null" ]]; then
        install_package_platform "$package" "linux" "$yaml_file"
    # Try all-platform installation
    elif [[ "$has_all" != "none" && "$has_all" != "null" ]]; then
        install_package_platform "$package" "all" "$yaml_file"
    else
    fi
    
    # Run post-install commands if any
    run_post_install "$package" "$yaml_file"
}

# Run post-install commands for a package
run_post_install() {
    local package="$1"
    local yaml_file="$2"
    
    # Check if package has post_install
    local has_post_install=$(yq eval ".packages.${package}.post_install // \"none\"" "$yaml_file")
    [[ "$has_post_install" == "none" || "$has_post_install" == "null" ]] && return 0
    
    # Check if there's a check command
    local check_cmd=$(yq eval ".packages.${package}.post_install.check // \"\"" "$yaml_file")
    if [[ -n "$check_cmd" && "$check_cmd" != "null" ]]; then
        if eval "$check_cmd" &>/dev/null; then
            return 0
        fi
    fi
    
    
    # Run post-install commands
    local commands=$(yq eval ".packages.${package}.post_install" "$yaml_file")
    
    # Check if it's an array or object
    if [[ "$commands" == *"commands:"* ]]; then
        # Object format with check and commands
        commands=$(yq eval ".packages.${package}.post_install.commands[]" "$yaml_file" 2>/dev/null || true)
    else
        # Array format
        commands=$(yq eval ".packages.${package}.post_install[]" "$yaml_file" 2>/dev/null || true)
    fi
    
    while IFS= read -r cmd; do
        [[ -z "$cmd" || "$cmd" == "null" ]] && continue
        eval "$cmd"
    done <<< "$commands"
}

# Install package using platform-specific method
install_package_platform() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    # Get installation methods for this platform
    local methods=$(yq eval ".packages.${package}.${platform} | keys | .[]" "$yaml_file" 2>/dev/null || true)
    
    while IFS= read -r method; do
        [[ -z "$method" ]] && continue
        
        case "$method" in
            homebrew)
                install_homebrew "$package" "$platform" "$yaml_file"
                ;;
            apt)
                install_apt "$package" "$platform" "$yaml_file"
                ;;
            pacman)
                install_pacman "$package" "$platform" "$yaml_file"
                ;;
            dnf)
                install_dnf "$package" "$platform" "$yaml_file"
                ;;
            winget)
                install_winget "$package" "$platform" "$yaml_file"
                ;;
            aur)
                install_aur "$package" "$platform" "$yaml_file"
                ;;
            script)
                install_script "$package" "$platform" "$yaml_file"
                ;;
            github)
                install_github "$package" "$platform" "$yaml_file"
                ;;
            cargo)
                install_cargo "$package" "$platform" "$yaml_file"
                ;;
            git_clone)
                install_git_clone "$package" "$platform" "$yaml_file"
                ;;
            apt_repository)
                install_apt_repository "$package" "$platform" "$yaml_file"
                ;;
            rpm_repository)
                install_rpm_repository "$package" "$platform" "$yaml_file"
                ;;
            copr)
                install_copr "$package" "$platform" "$yaml_file"
                ;;
            python)
                install_python "$package" "$platform" "$yaml_file"
                ;;
        esac
    done <<< "$methods"
}

# Installation method implementations
install_homebrew() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    # Check if it's a cask
    local brew_package=$(yq eval ".packages.${package}.${platform}.homebrew" "$yaml_file")
    if [[ "$brew_package" == *"cask:"* ]]; then
        local cask_name=$(yq eval ".packages.${package}.${platform}.homebrew.cask" "$yaml_file")
        brew list --cask "$cask_name" &>/dev/null || brew install --cask "$cask_name"
    else
        brew list "$brew_package" &>/dev/null || brew install "$brew_package"
    fi
}

install_apt() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    local apt_package=$(yq eval ".packages.${package}.${platform}.apt" "$yaml_file")
    dpkg -l "$apt_package" &>/dev/null || sudo apt install -y "$apt_package"
}

install_pacman() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    local pacman_package=$(yq eval ".packages.${package}.${platform}.pacman" "$yaml_file")
    pacman -Q "$pacman_package" &>/dev/null || sudo pacman -S --needed --noconfirm "$pacman_package"
}

install_dnf() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    local dnf_package=$(yq eval ".packages.${package}.${platform}.dnf" "$yaml_file")
    rpm -q "${dnf_package#@}" &>/dev/null || sudo dnf install -y "$dnf_package"
}

install_winget() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    local winget_package=$(yq eval ".packages.${package}.${platform}.winget" "$yaml_file")
    winget list --id "$winget_package" &>/dev/null || winget install --id "$winget_package" --accept-package-agreements --accept-source-agreements
}

install_aur() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    local aur_package=$(yq eval ".packages.${package}.${platform}.aur" "$yaml_file")
    
    # Determine AUR helper
    local aur_helper=""
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        warning "No AUR helper found, skipping $aur_package"
        return
    fi
    
    "$aur_helper" -Q "$aur_package" &>/dev/null || "$aur_helper" -S --needed --noconfirm "$aur_package"
}

install_script() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    # Skip if already installed
    command -v "$package" &>/dev/null && return 0
    
    local script=$(yq eval ".packages.${package}.${platform}.script" "$yaml_file")
    info "Installing $package via script..."
    eval "$script"
}

install_github() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    # Skip if already installed
    command -v "$package" &>/dev/null && return 0
    
    local repo=$(yq eval ".packages.${package}.${platform}.github.repo" "$yaml_file")
    local pattern=$(yq eval ".packages.${package}.${platform}.github.asset_pattern" "$yaml_file")
    local type=$(yq eval ".packages.${package}.${platform}.github.type" "$yaml_file")
    local binary=$(yq eval ".packages.${package}.${platform}.github.binary // \"$package\"" "$yaml_file")
    
    info "Installing $package from GitHub..."
    
    # Get latest version
    local version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -Po '"tag_name": "\K[^"]*' | sed 's/^v//')
    local url=$(printf "$pattern" "$version" "$version")
    
    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    
    case "$type" in
        deb)
            curl -LO "https://github.com/$repo/releases/download/$version/$url"
            sudo dpkg -i *.deb || sudo apt-get install -f -y
            ;;
        rpm)
            curl -LO "https://github.com/$repo/releases/download/$version/$url"
            sudo rpm -i *.rpm
            ;;
        tar)
            curl -sL "https://github.com/$repo/releases/download/$version/$url" | tar -xz
            [[ -f "$binary" ]] && sudo mv "$binary" "/usr/local/bin/$binary"
            ;;
        zip)
            curl -sLO "https://github.com/$repo/releases/download/$version/$url"
            unzip -j -o *.zip "$binary" || unzip -o *.zip
            [[ -f "$binary" ]] && sudo mv "$binary" "/usr/local/bin/$binary"
            ;;
        binary)
            curl -sL "https://github.com/$repo/releases/download/$version/$url" -o "$binary"
            chmod +x "$binary"
            sudo mv "$binary" "/usr/local/bin/$binary"
            ;;
    esac
    
    cd - >/dev/null
    rm -rf "$tmp_dir"
}

install_cargo() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    command -v "$package" &>/dev/null && return 0
    
    local cargo_package=$(yq eval ".packages.${package}.${platform}.cargo" "$yaml_file")
    info "Installing $cargo_package via cargo..."
    cargo install "$cargo_package"
}

install_git_clone() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    local repo=$(yq eval ".packages.${package}.${platform}.git_clone.repo" "$yaml_file")
    local dest=$(eval echo $(yq eval ".packages.${package}.${platform}.git_clone.dest" "$yaml_file"))
    
    [[ -d "$dest" ]] && return 0
    
    info "Cloning $repo to $dest..."
    git clone "$repo" "$dest"
}

install_apt_repository() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    local key_url=$(yq eval ".packages.${package}.${platform}.apt_repository.key_url" "$yaml_file")
    local repo=$(yq eval ".packages.${package}.${platform}.apt_repository.repo" "$yaml_file")
    local apt_package=$(yq eval ".packages.${package}.${platform}.apt_repository.package" "$yaml_file")
    local extra_setup=$(yq eval ".packages.${package}.${platform}.apt_repository.extra_setup // \"\"" "$yaml_file")
    
    # Add repository if package not installed
    if ! dpkg -l "$apt_package" &>/dev/null 2>&1; then
        info "Adding APT repository for $package..."
        
        # Add GPG key
        local keyring_path="/usr/share/keyrings/${package}-archive-keyring.gpg"
        curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring_path"
        
        # Add repository
        echo "$repo" | sudo tee "/etc/apt/sources.list.d/${package}.list" > /dev/null
        
        # Run extra setup if needed
        if [[ -n "$extra_setup" && "$extra_setup" != "null" ]]; then
            eval "$extra_setup"
        fi
        
        sudo apt update
        sudo apt install -y "$apt_package"
    fi
}

install_rpm_repository() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    local key_url=$(yq eval ".packages.${package}.${platform}.rpm_repository.key_url" "$yaml_file")
    local repo_config=$(yq eval ".packages.${package}.${platform}.rpm_repository.repo_config" "$yaml_file")
    local rpm_package=$(yq eval ".packages.${package}.${platform}.rpm_repository.package" "$yaml_file")
    
    if ! rpm -q "$rpm_package" &>/dev/null 2>&1; then
        info "Adding RPM repository for $package..."
        
        # Import GPG key
        sudo rpm --import "$key_url"
        
        # Add repository
        echo "$repo_config" | sudo tee "/etc/yum.repos.d/${package}.repo" > /dev/null
        
        sudo dnf install -y "$rpm_package"
    fi
}

install_copr() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    local copr_repo=$(yq eval ".packages.${package}.${platform}.copr.repo" "$yaml_file")
    local copr_package=$(yq eval ".packages.${package}.${platform}.copr.package" "$yaml_file")
    
    if ! command -v "$copr_package" &>/dev/null; then
        sudo dnf copr enable -y "$copr_repo"
        sudo dnf install -y "$copr_package"
    fi
}

install_python() {
    local package="$1"
    local platform="$2"
    local yaml_file="$3"
    
    command -v "$package" &>/dev/null && return 0
    
    local method=$(yq eval ".packages.${package}.python | keys | .[0]" "$yaml_file")
    local pkg_name=$(yq eval ".packages.${package}.python.${method}" "$yaml_file")
    
    case "$method" in
        uv)
            command -v uv &>/dev/null || return 1
            uv tool install "$pkg_name"
            ;;
        pip)
            pip install --user "$pkg_name"
            ;;
    esac
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
    install_from_yaml "$platform" "$PACKAGES_FILE"
    
    success "Installation and configuration complete!"
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