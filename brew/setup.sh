#!/bin/bash

packages=(
  jq
  lazygit
  mise
  neovim
  pnpm
  wget
  watchman
  spaceship
)

casks=(
  ngrok
)

if ! command -v brew &> /dev/null; then
  echo "Brew is not installed. Installing Brew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing Brew packages..."
for package in "${packages[@]}"; do
  if brew list "$package" --formula &> /dev/null; then
    echo "$package is already installed."
  else
    echo "Installing $package..."
    brew install "$package"
  fi
done

echo "Installing Brew casks..."
for cask in "${casks[@]}"; do
  if brew list "$cask" --cask &> /dev/null; then
    echo "$cask is already installed."
  else
    echo "Installing $cask..."
    brew install "$cask"
  fi
done

echo "Brew setup complete."
