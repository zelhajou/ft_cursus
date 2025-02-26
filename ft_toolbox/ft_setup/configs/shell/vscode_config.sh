# VS Code configuration for 42 ToolBox
# Store VS Code settings on external drive

# Set VS Code directories
export VSCODE_EXTENSIONS="/Volumes/BrainFuck/42_ToolBox/vscode/extensions"
export VSCODE_USER_DATA_DIR="/Volumes/BrainFuck/42_ToolBox/vscode/user-data"

# Create directories if they don't exist
mkdir -p "$VSCODE_EXTENSIONS"
mkdir -p "$VSCODE_USER_DATA_DIR"

# Simple function to launch VS Code with settings from external drive
vscode() {
  # If no arguments, just open VS Code
  if [ $# -eq 0 ]; then
    open -a "Visual Studio Code" --args --extensions-dir="$VSCODE_EXTENSIONS" --user-data-dir="$VSCODE_USER_DATA_DIR"
  else
    # If arguments are provided, open files with VS Code
    open -a "Visual Studio Code" "$@" --args --extensions-dir="$VSCODE_EXTENSIONS" --user-data-dir="$VSCODE_USER_DATA_DIR"
  fi
}

# Create code alias that uses our function
alias code="vscode"

# Original VS Code command
alias default-code="open -a 'Visual Studio Code'"