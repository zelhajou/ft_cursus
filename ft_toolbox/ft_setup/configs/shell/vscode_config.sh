# VS Code configuration for 42 ToolBox
# Store VS Code settings on external drive

# Set VS Code directories
export VSCODE_EXTENSIONS="/Volumes/BrainFuck/42_ToolBox/vscode/extensions"
export VSCODE_USER_DATA_DIR="/Volumes/BrainFuck/42_ToolBox/vscode/user-data"

# Create directories if they don't exist
mkdir -p "$VSCODE_EXTENSIONS"
mkdir -p "$VSCODE_USER_DATA_DIR"

# Create a launcher script for VS Code
cat > "/Volumes/BrainFuck/42_ToolBox/bin/code-launcher.sh" << 'EOF'
#!/bin/bash
# VS Code launcher that uses external drive for extensions

VSCODE_EXTENSIONS="/Volumes/BrainFuck/42_ToolBox/vscode/extensions"
VSCODE_USER_DATA_DIR="/Volumes/BrainFuck/42_ToolBox/vscode/user-data"

# Ensure directories exist
mkdir -p "$VSCODE_EXTENSIONS"
mkdir -p "$VSCODE_USER_DATA_DIR"

# Launch VS Code
if [ $# -eq 0 ]; then
  # No arguments
  open -a "Visual Studio Code" --args --extensions-dir="$VSCODE_EXTENSIONS" --user-data-dir="$VSCODE_USER_DATA_DIR"
else
  # With arguments (files to open)
  open -a "Visual Studio Code" "$@" --args --extensions-dir="$VSCODE_EXTENSIONS" --user-data-dir="$VSCODE_USER_DATA_DIR"
fi
EOF

# Make it executable
mkdir -p "/Volumes/BrainFuck/42_ToolBox/bin"
chmod +x "/Volumes/BrainFuck/42_ToolBox/bin/code-launcher.sh"

# Create alias for the launcher
alias code="/Volumes/BrainFuck/42_ToolBox/bin/code-launcher.sh"

# Original VS Code command
alias default-code="open -a 'Visual Studio Code'"