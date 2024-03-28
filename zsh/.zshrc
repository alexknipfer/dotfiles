# Add Python to the PATH
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# Set up Android SDK
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# Path to your oh-my-zsh installation.
export ZSH="/Users/alexknipfer/.oh-my-zsh"

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

# Initialize Homebrew for use in the shell
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add yq to the PATH
export PATH="/usr/local/opt/yq@3/bin:$PATH"

# Add yarn to the PATH
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Set up pnpm
export PNPM_HOME="/Users/alexknipfer/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# End pnpm setup

# Source PHPBrew bashrc if it exists
[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc

# Activate mise for Zsh
eval "$(/opt/homebrew/bin/mise activate zsh)"
