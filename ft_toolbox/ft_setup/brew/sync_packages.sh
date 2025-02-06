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

# Function to add package to list if not already present
add_to_list() {
    local package="$1"
    if ! grep -q "^${package}$" "$PACKAGE_LIST" 2>/dev/null; then
        echo "$package" >> "$PACKAGE_LIST"
        echo "Added $package to $PACKAGE_LIST"
    fi
}

# Create package list if it doesn't exist
if [ ! -f "$PACKAGE_LIST" ]; then
    echo "Creating new package list file: $PACKAGE_LIST"
    touch "$PACKAGE_LIST"
fi

# Add currently installed packages to the list
echo "Checking currently installed packages..."
echo "Adding formula packages..."
brew list --formula | while read -r package; do
    add_to_list "$package"
done

echo "Adding cask packages..."
brew list --cask | while read -r package; do
    add_to_list "$package"
done

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