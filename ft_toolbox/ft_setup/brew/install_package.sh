#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored status messages
print_status() {
    local message=$1
    local status=$2
    if [ "$status" = "success" ]; then
        echo -e "${GREEN}✅ ${message}${NC}"
    else
        echo -e "${RED}❌ ${message}${NC}"
    fi
}

# Function to check if brew package exists
check_brew_package() {
    local package=$1
    if brew info "$package" &>/dev/null; then
        return 0
    elif brew info --cask "$package" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to install brew package
install_brew_package() {
    local package=$1
    local install_output
    
    # Try installing as formula first
    if install_output=$(brew install "$package" 2>&1); then
        print_status "Successfully installed $package as formula" "success"
        return 0
    fi
    
    # If formula install fails, try as cask
    if install_output=$(brew install --cask "$package" 2>&1); then
        print_status "Successfully installed $package as cask" "success"
        return 0
    fi
    
    print_status "Failed to install $package" "error"
    echo "Installation output:"
    echo "$install_output"
    return 1
}

# Function to sync with git
sync_with_git() {
    local package=$1
    local commit_msg="Add $package to package list"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_status "Not a git repository" "error"
        return 1
    }
    
    # Check if there are changes to commit
    if ! git diff --quiet "$PACKAGE_LIST"; then
        # Sync with remote
        if ! git pull --rebase origin main 2>/dev/null; then
            print_status "Failed to sync with remote repository" "error"
            return 1
        fi
        
        # Add and commit changes
        git add "$PACKAGE_LIST"
        if ! git commit -m "$commit_msg" 2>/dev/null; then
            print_status "Failed to commit changes" "error"
            return 1
        fi
        
        # Push changes
        if ! git push 2>/dev/null; then
            print_status "Failed to push changes" "error"
            return 1
        fi
        
        print_status "Successfully synced with GitHub" "success"
    else
        echo "No changes to sync"
    fi
}

# Main script
main() {
    # Ensure a package name is provided
    if [ -z "$1" ]; then
        echo "Usage: $0 <package-name>"
        exit 1
    fi

    PACKAGE_NAME=$1
    PACKAGE_LIST="brew-packages.txt"

    # Create package list file if it doesn't exist
    touch "$PACKAGE_LIST" 2>/dev/null || {
        print_status "Cannot create/access $PACKAGE_LIST" "error"
        exit 1
    }

    # Check if the package exists in brew
    if ! check_brew_package "$PACKAGE_NAME"; then
        print_status "Package $PACKAGE_NAME not found in brew repository" "error"
        exit 1
    fi

    # Check if the package is already in the list
    if grep -q "^$PACKAGE_NAME\$" "$PACKAGE_LIST" 2>/dev/null; then
        print_status "$PACKAGE_NAME is already recorded in $PACKAGE_LIST" "success"
    else
        # Install the package and add it to the list
        echo "Installing $PACKAGE_NAME..."
        if install_brew_package "$PACKAGE_NAME"; then
            echo "$PACKAGE_NAME" >> "$PACKAGE_LIST"
            print_status "$PACKAGE_NAME added to $PACKAGE_LIST" "success"
            
            # Sort package list alphabetically and remove duplicates
            sort -u "$PACKAGE_LIST" -o "$PACKAGE_LIST"
            
            # Sync with GitHub
            echo "Syncing $PACKAGE_LIST with GitHub..."
            if ! sync_with_git "$PACKAGE_NAME"; then
                print_status "Failed to sync with GitHub, but package was installed" "error"
                exit 1
            fi
        else
            print_status "Failed to install $PACKAGE_NAME" "error"
            exit 1
        fi
    fi

    echo -e "\n🎉 Operation completed successfully!"
}

main "$1"