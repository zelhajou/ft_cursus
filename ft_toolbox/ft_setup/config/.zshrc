                                          
ZSH_DISABLE_COMPFIX="true"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
alias ll='ls -la'
alias g='git'
alias c='clear'

# Set default editor
export EDITOR='vim'


# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "/Volumes/BrainFuck/42_ToolBox/homebrew/opt/nvm/nvm.sh" ] && \. "/Volumes/BrainFuck/42_ToolBox/homebrew/opt/nvm/nvm.sh"
[ -s "/Volumes/BrainFuck/42_ToolBox/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/Volumes/BrainFuck/42_ToolBox/homebrew/opt/nvm/etc/bash_completion.d/nvm"


####10108bleach10108####
alias storage="bash /Users/zelhajou/.bleach_42/check_space.bash"
alias bleach="bash /Users/zelhajou/.bleach_42/help.bash"
alias unbleach="bash /Users/zelhajou/.bleach_42/unbleach.bash"
alias bdocker="bash /Users/zelhajou/.bleach_42/init_docker.bash"
alias bclean="bash /Users/zelhajou/.bleach_42/cleaner.bash"
alias bcleanfull="bash /Users/zelhajou/.bleach_42/cleanAllAppsData.bash"
/bin/bash /Users/zelhajou/.bleach_42/cleaner.bash
####10108bleach10108####

source /Volumes/BrainFuck/42_ToolBox/configs/shell/brew_config.sh

source /Users/zelhajou/.docker/init-zsh.sh || true # Added by Docker Desktop

export PATH="/Volumes/BrainFuck/42_ToolBox/homebrew/heroku/heroku/bin:$PATH"
