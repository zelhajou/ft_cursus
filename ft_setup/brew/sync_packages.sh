#!/bin/bash

PACKAGE_LIST="brew-packages.txt"

# Function to trim whitespace from a string
trim() {
    local var="$*"
    # Remove leading and trailing whitespace
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

# Check if package list exists
if [ ! -f "$PACKAGE_LIST" ]; then
    echo "Package list file ($PACKAGE_LIST) not found!"
    exit 1
fi

echo "Syncing packages from $PACKAGE_LIST..."

# Read file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Trim whitespace
    package=$(trim "$line")
    
    # Skip empty lines and comments
    if [ -z "$package" ] || [[ "$package" =~ ^# ]]; then
        continue
    fi
    
    # Check if package is already installed
    if ! brew list --formula | grep -q "^$package\$" && ! brew list --cask | grep -q "^$package\$"; then
        echo "Installing $package..."
        
        # Try installing as formula first, then as cask if that fails
        if ! brew install "$package" 2>/dev/null; then
            echo "Attempting to install $package as a cask..."
            if ! brew install --cask "$package" 2>/dev/null; then
                echo "❌ Failed to install $package as either formula or cask"
                continue
            fi
        fi
        echo "✅ Successfully installed $package"
    else
        echo "✅ $package is already installed"
    fi
done < "$PACKAGE_LIST"

echo -e "\n🎉 Package installation completed!"

# Display installed packages summary
echo -e "\nInstalled Packages Summary:"
echo "Formula packages:"
brew list --formula
echo -e "\nCask packages:"
brew list --cask