# VS Code configuration for 42 ToolBox - Simplified version
# Automatically setup VS Code to use external drive

# External drive paths
TOOLBOX_DIR="/Volumes/BrainFuck/42_ToolBox"
VSCODE_EXT_DIR="$TOOLBOX_DIR/vscode/extensions"

# Ensure directories exist (no copying)
mkdir -p "$VSCODE_EXT_DIR"

# Setup symlink quietly without copying files
if [ -d "$TOOLBOX_DIR" ]; then
  # Only create symlink if it doesn't exist
  if [ ! -L "$HOME/.vscode/extensions" ]; then
    echo "Setting up VS Code extensions symlink..."
    
    # Backup existing directory if needed
    if [ -d "$HOME/.vscode/extensions" ]; then
      mv "$HOME/.vscode/extensions" "$HOME/.vscode/extensions.old"
    else
      mkdir -p "$HOME/.vscode"
    fi
    
    # Create the symlink
    ln -sf "$VSCODE_EXT_DIR" "$HOME/.vscode/extensions"
    echo "VS Code symlink created."
  fi
fi

# Create aliases
alias code="open -a 'Visual Studio Code'"
alias default-code="open -a 'Visual Studio Code'"