#!/bin/bash

check_dependencies() {
    local missing=()
    
    for dep in "${REQUIRED_DEPS[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠️  The following required dependencies are missing:"
        for dep in "${missing[@]}"; do
            echo "   - $dep"
        done
        echo ""
        return 1
    fi
    return 0
}

install_deps() {
    local missing_deps=("$@")
    
    # Detect OS
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        os=$ID
    elif [[ $(uname) == "Darwin" ]]; then
        os="macos"
    else
        echo "Unsupported OS"
        return 1
    fi

    # Detect WSL
    if grep -qi "microsoft" /proc/version 2>/dev/null || [[ -n "$WSL_DISTRO_NAME" ]]; then
        os="wsl-$os"
    fi

    echo -e "\033[0;32mInstalling dependencies: ${missing_deps[*]}\033[0m"

    case $os in
        ubuntu|debian|linuxmint|wsl-ubuntu|wsl-debian)
            sudo apt update -y
            sudo apt install -y "${missing_deps[@]}"
            ;;
        centos|rhel|fedora|wsl-centos|wsl-rhel|wsl-fedora)
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y "${missing_deps[@]}"
            else
                sudo yum install -y "${missing_deps[@]}"
            fi
            ;;
        arch|manjaro|wsl-arch|wsl-manjaro)
            sudo pacman -Sy --noconfirm "${missing_deps[@]}"
            ;;
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                echo "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install "${missing_deps[@]}"
            ;;
        *)
            echo "Unsupported OS: $os"
            return 1
            ;;
    esac
}

verify_ghostty_install() {
    if ! command -v ghostty >/dev/null 2>&1; then
        echo "Error: Ghostty terminal is not installed"
        echo "Please install Ghostty first: https://ghostty.org/"
        exit 1
    fi
    
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
        echo "Created Ghostty config directory"
    fi
}

prompt_install_dependencies() {
    local missing_deps=("$@")
    
    # Ask user for confirmation
    read -p "Do you want to install these dependencies? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_deps "${missing_deps[@]}"
        if [ $? -eq 0 ]; then
            echo -e "${COLOR_SUCCESS}✓ Dependencies installed successfully!${COLOR_RESET}"
            return 0
        else
            echo -e "${COLOR_ERROR}✗ Failed to install dependencies${COLOR_RESET}"
            return 1
        fi
    else
        echo -e "${COLOR_ERROR}❌ Installation cancelled. Some features may not work without these dependencies.${COLOR_RESET}"
        return 1
    fi
}
