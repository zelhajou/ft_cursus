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

# Function to configure git
configure_git() {
    echo "Configuring Git..."
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email

    if git config --global user.name "$git_username" && \
       git config --global user.email "$git_email"; then
        print_success "Git configured successfully"
        return 0
    else
        print_error "Failed to configure Git"
        return 1
    fi
}

# Function to setup SSH for Intra
setup_ssh() {
    echo "Setting up SSH for Intra..."
    
    # Generate SSH key
    SSH_KEY_PATH="$HOME/.ssh/id_rsa"
    if [ -f "$SSH_KEY_PATH" ]; then
        read -p "SSH key already exists. Generate new one? (y/n): " regenerate
        if [ "$regenerate" != "y" ]; then
            print_success "Using existing SSH key"
            return 0
        fi
    fi

    read -p "Enter your Intra email: " intra_email
    
    # Generate new SSH key
    if ssh-keygen -t rsa -b 4096 -C "$intra_email" -f "$SSH_KEY_PATH" -N "" <<<y >/dev/null 2>&1; then
        print_success "SSH key generated"
    else
        print_error "Failed to generate SSH key"
        return 1
    fi

    # Start SSH agent and add key
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    ssh-add "$SSH_KEY_PATH" >/dev/null 2>&1

    # Display the public key
    echo -e "\nYour public SSH key is:"
    cat "$SSH_KEY_PATH.pub"
    echo -e "\nPlease add this key to your Intra profile (https://intra.42.fr/)"
    echo "Steps: Profile -> SSH Keys -> Add SSH Key"
    
    print_success "SSH setup completed"
}

# Function to setup ZSH
setup_zsh() {
    echo "Setting up ZSH..."

    # Check if zsh is installed
    if ! command -v zsh &> /dev/null; then
        print_error "ZSH is not installed. Please install ZSH first."
        return 1
    fi

    # Install Oh My Zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Install zsh-autosuggestions plugin
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi

    # Install zsh-syntax-highlighting plugin
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

    # Backup existing .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
        print_info "Backed up existing .zshrc to .zshrc.backup"
    fi

    # Configure .zshrc
    cat > "$HOME/.zshrc" << 'EOL'
ZSH_DISABLE_COMPFIX="true"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    npm
    node
    vscode
    web-search
    copypath
    copyfile
    dirhistory
    history
)

source $ZSH/oh-my-zsh.sh

# User configuration
alias ll='ls -la'
alias g='git'
alias c='clear'

# Set default editor
export EDITOR='vim'

# Add Homebrew to PATH
source /Volumes/BrainFuck/42_ToolBox/configs/shell/brew_config.sh

# Add NPM config
source /Volumes/BrainFuck/42_ToolBox/configs/shell/npm_config.sh

# Add VS Code config
source /Volumes/BrainFuck/42_ToolBox/configs/shell/vscode_config.sh


vscode_clean() {
  echo "Cleaning VS Code caches..."
  rm -rf ~/Library/Caches/com.microsoft.VSCode*
  echo "Done."
}

EOL

    # Change default shell to zsh if it's not already
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s $(which zsh)
        print_info "Default shell changed to ZSH. Please log out and log back in for changes to take effect."
    fi

    print_success "ZSH setup completed"
}

# Function to install bclean (optional)
install_bclean() {
    echo "Would you like to install bclean (a tool for cleaning files)?"
    read -p "Install bclean? (y/n): " install_choice
    
    if [ "$install_choice" = "y" ]; then
        echo "Installing bclean..."
        REPO_URL="https://github.com/Ra-Wo/bleach_42"
        
        if git clone "$REPO_URL" ~/.bleach_42 && \
           cd ~/.bleach_42 && \
           chmod +x install.bash && \
           ./install.bash; then
            print_success "bclean installed successfully"
        else
            print_error "Failed to install bclean"
            return 1
        fi
    fi
}

# Main script
main() {
    echo "Starting initial setup..."
    print_info "This script will set up Git, SSH, ZSH, and optionally install bclean."
    echo
    
    # Configure git
    configure_git || exit 1
    
    # Setup SSH
    setup_ssh || exit 1
    
    # Setup ZSH
    setup_zsh || exit 1
    
    # Install bclean (optional)
    install_bclean
    
    print_success "Initial setup completed successfully!"
    print_info "Please restart your terminal for all changes to take effect."
}

# Run main function
main