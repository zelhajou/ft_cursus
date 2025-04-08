# NPM configuration for 42 ToolBox
export NPM_CONFIG_PREFIX="/Volumes/BrainFuck/42_ToolBox/npm-global"
export PATH="/Volumes/BrainFuck/42_ToolBox/npm-global/bin:$PATH"

# Configure npm cache location on external drive
export NPM_CONFIG_CACHE="/Volumes/BrainFuck/42_ToolBox/cache/npm-cache"

# Ensure directories exist
mkdir -p "$NPM_CONFIG_PREFIX/bin"
mkdir -p "$NPM_CONFIG_CACHE"

# Apply npm configurations (suppress output to avoid errors when sourcing)
npm config set prefix "$NPM_CONFIG_PREFIX" > /dev/null 2>&1
npm config set cache "$NPM_CONFIG_CACHE" > /dev/null 2>&1

# Optional: Set additional npm configurations
npm config set fund false > /dev/null 2>&1  # Disable funding messages
npm config set loglevel warn > /dev/null 2>&1  # Only show warnings and errors