#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to get installation location
setup_installation_path() {
    while true; do
        echo "Where would you like to install Homebrew?"
        echo "1) goinfre (local machine installation)"
        echo "2) External hard disk"
        printf "Please choose (1/2): "
        read -r choice
        echo

        case $choice in
            1)
                BASE_PATH="$HOME/goinfre"
                break
                ;;
            2)
                # List available external drives
                echo "Available external drives:"
                ls -1 /Volumes
                echo
                printf "Enter the name of your external drive: "
                read -r drive_name
                if [ -d "/Volumes/$drive_name" ]; then
                    BASE_PATH="/Volumes/$drive_name"
                    break
                else
                    print_error "Drive not found. Please try again."
                fi
                ;;
            *)
                print_error "Invalid choice. Please try again."
                ;;
        esac
    done
    
    # Create the directory structure
    TOOLBOX_PATH="$BASE_PATH/42_ToolBox"
    mkdir -p "$TOOLBOX_PATH"/{homebrew,cache/homebrew-cache,configs/shell}
    
    # Save the path to a config file
    echo "export TOOLBOX_PATH=\"$TOOLBOX_PATH\"" > "$HOME/.toolbox_config"
    print_success "Directory structure created at: $TOOLBOX_PATH"
}

# Function to setup Homebrew environment variables
setup_brew_env() {
    local brew_path="$1"
    local cache_path="$2"
    local shell_config="$HOME/.$(basename $SHELL)rc"
    local brew_config="$TOOLBOX_PATH/configs/shell/brew_config.sh"
    
    mkdir -p "$(dirname "$brew_config")"
    {
        echo "# Homebrew configuration for 42 ToolBox"
        echo "export PATH=\"$brew_path/bin:\$PATH\""
        echo "export HOMEBREW_CACHE=\"$cache_path\""
        echo "eval \"\$($brew_path/bin/brew shellenv)\""
    } > "$brew_config"
    
    # Add source line to shell config if it doesn't exist
    if ! grep -q "source $brew_config" "$shell_config"; then
        echo "source $brew_config" >> "$shell_config"
    fi
    
    # Source the config file
    source "$brew_config"
    eval "$($brew_path/bin/brew shellenv)"
}

# Function to setup Homebrew
setup_homebrew() {
    # Get installation path if TOOLBOX_PATH is not set
    if [ ! -f "$HOME/.toolbox_config" ]; then
        setup_installation_path
    else
        source "$HOME/.toolbox_config"
    fi

    local brew_path="$TOOLBOX_PATH/homebrew"
    local cache_path="$TOOLBOX_PATH/cache/homebrew-cache"
    
    # Create and ensure cache directory exists in correct location
    mkdir -p "$cache_path"
    
    # Check if Homebrew is already installed
    if [ -d "$brew_path" ] && [ -f "$brew_path/bin/brew" ]; then
        print_info "Homebrew already installed in $brew_path"
        print_info "Reconfiguring environment variables..."
        setup_brew_env "$brew_path" "$cache_path"
        
        print_info "Updating Homebrew..."
        brew update --quiet
        print_success "Homebrew is up to date and configured"
    else
        echo "Setting up Homebrew in: $brew_path"
        mkdir -p "$brew_path"
        
        # Ensure we're in the correct directory
        cd "$brew_path" || {
            print_error "Could not change to directory: $brew_path"
            exit 1
        }
        
        echo "Cloning Homebrew..."
        git clone https://github.com/Homebrew/brew . &>/dev/null || {
            print_error "Failed to clone Homebrew repository"
            exit 1
        }
        
        setup_brew_env "$brew_path" "$cache_path"
        brew update --force --quiet &>/dev/null
        print_success "Homebrew installed in $brew_path"
    fi
}

# Function to install packages from brew-packages.txt
install_packages() {
    # Get the script's directory and handle the case where it's in the brew subdirectory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local packages_file
    
    # Check if brew-packages.txt exists in current directory or parent directory
    if [ -f "$SCRIPT_DIR/brew-packages.txt" ]; then
        packages_file="$SCRIPT_DIR/brew-packages.txt"
    elif [ -f "$SCRIPT_DIR/../brew/brew-packages.txt" ]; then
        packages_file="$SCRIPT_DIR/../brew/brew-packages.txt"
    else
        print_error "Could not find brew-packages.txt"
        return 1
    fi
    
    if [ -f "$packages_file" ]; then
        echo "Installing/Updating packages from brew-packages.txt..."
        while IFS= read -r package || [ -n "$package" ]; do
            # Skip empty lines and comments
            [[ -z "$package" || "$package" =~ ^# ]] && continue
            
            if brew list "$package" &>/dev/null; then
                print_info "Updating $package..."
                brew upgrade "$package" 2>/dev/null || true
            else
                echo "Installing $package..."
                if ! brew install "$package" 2>/dev/null; then
                    if ! brew install --cask "$package" 2>/dev/null; then
                        print_error "Failed to install $package"
                        continue
                    fi
                fi
            fi
            print_success "$package installed/updated"
        done < "$packages_file"
    else
        print_error "brew-packages.txt not found at $packages_file"
    fi
}

# Function to display directory structure
display_structure() {
    echo -e "\nDirectory Structure Created:"
    echo "42_ToolBox/"
    echo "├── homebrew/          (Homebrew installation)"
    echo "├── cache/"
    echo "│   └── homebrew-cache (Homebrew cache)"
    echo "└── configs/"
    echo "    └── shell/        (Shell configurations)"
}

# Main script
main() {
    # Setup/Update Homebrew
    setup_homebrew
    
    # Display the created directory structure
    display_structure
    
    # Install/Update packages
    install_packages
    
    print_success "Homebrew setup/update completed successfully 🎉"
    echo "Please restart your terminal or run 'source $HOME/.$(basename $SHELL)rc' to apply the changes."
}

main