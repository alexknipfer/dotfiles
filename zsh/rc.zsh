source_if_exists () {
    if test -r "$1"; then
        source "$1"
    fi
}

source_if_exists $HOME/.env.sh
source_if_exists $DOTFILES/zsh/aliases.zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set the theme for your Zsh prompt
ZSH_THEME="spaceship"
SPACESHIP_PACKAGE_SHOW=false

# Configure plugins for Zsh
plugins=(
  git
  zsh-autosuggestions
)

# Disable zsh compfix (may improve performance)
ZSH_DISABLE_COMPFIX=true

# Initialize oh-my-zsh
source $ZSH/oh-my-zsh.sh

precmd() {
  source $DOTFILES/zsh/aliases.zsh
}

# Initialize Homebrew for use in the shell
eval "$(/opt/homebrew/bin/brew shellenv)"

# Activate mise for Zsh
eval "$(/opt/homebrew/bin/mise activate zsh)"
