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

# Function to get Docker path
setup_docker_path() {
    while true; do
        echo "Where would you like to store Docker data?"
        echo "1) goinfre (local machine storage)"
        echo "2) External hard disk"
        printf "Please choose (1/2): "
        read -r choice
        echo

        case $choice in
            1)
                DOCKER_DATA_PATH="$HOME/goinfre/42_ToolBox/docker/data"
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
                    DOCKER_DATA_PATH="/Volumes/$drive_name/42_ToolBox/docker/data"
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

    # Create Docker data directory structure
    mkdir -p "$DOCKER_DATA_PATH"
    print_success "Docker data directory created at: $DOCKER_DATA_PATH"
}

# Function to start Docker and wait for initialization
start_and_wait_docker() {
    print_info "Starting Docker Desktop..."
    open -a "Docker Desktop"
    
    print_info "Waiting for Docker to initialize..."
    while ! docker info &>/dev/null; do
        echo -n "."
        sleep 1
    done
    echo
    print_success "Docker is running"
    sleep 5  # Give it a few more seconds to fully initialize
}

# Function to stop Docker Desktop
stop_docker() {
    print_info "Stopping Docker Desktop..."
    osascript -e 'quit app "Docker Desktop"'
    sleep 5
}

# Function to update Docker settings
update_docker_settings() {
    local settings_file="$HOME/Library/Group Containers/group.com.docker/settings.json"
    
    # Backup original settings
    if [ -f "$settings_file" ]; then
        cp "$settings_file" "${settings_file}.backup"
        print_info "Original settings backed up to ${settings_file}.backup"
        
        # Update settings file
        sed -i '' "s|\"dataFolder\": \".*\"|\"dataFolder\": \"$DOCKER_DATA_PATH\"|" "$settings_file"
        print_success "Docker settings updated"
    else
        print_error "Docker settings file not found"
        exit 1
    fi
}

# Main script
main() {
    echo "Starting Docker setup..."
    print_info "This script will update Docker Desktop data location."
    print_info "Please make sure Docker Desktop is installed."
    echo

    # First, start Docker to create default settings
    start_and_wait_docker
    
    # Setup Docker path
    setup_docker_path
    
    # Stop Docker Desktop
    stop_docker
    
    # Update Docker settings
    update_docker_settings
    
    echo
    print_success "Docker data path has been updated! 🎉"
    echo "New path: $DOCKER_DATA_PATH"
    echo
    print_info "Please:"
    echo "1. Start Docker Desktop"
    echo "2. Go to Preferences > Resources"
    echo "3. Verify the disk image location has been updated"
    echo "4. Apply & Restart Docker Desktop"
}

main