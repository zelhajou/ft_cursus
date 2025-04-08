# Homebrew configuration for 42 ToolBox
export PATH="/Volumes/BrainFuck/42_ToolBox/homebrew/bin:$PATH"
export HOMEBREW_CACHE="/Volumes/BrainFuck/42_ToolBox/cache/homebrew-cache"
eval "$(/Volumes/BrainFuck/42_ToolBox/homebrew/bin/brew shellenv)"

# NVM Configuration 
export NVM_DIR="$HOME/.nvm"
[ -s "/Volumes/BrainFuck/42_ToolBox/homebrew/opt/nvm/nvm.sh" ] && \. "/Volumes/BrainFuck/42_ToolBox/homebrew/opt/nvm/nvm.sh"
[ -s "/Volumes/BrainFuck/42_ToolBox/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/Volumes/BrainFuck/42_ToolBox/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Remove any existing Node from PATH
path=("${path[@]:#*/heroku/*/node*}")

export PATH="/Volumes/BrainFuck/42_ToolBox/homebrew/heroku/heroku/bin:$PATH"