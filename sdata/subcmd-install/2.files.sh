#!/usr/bin/env bash

# Step 2: Install Configuration Files
echo "Installing configuration files..."

# Copy everything from the repo's config folder to ~/.config/
mkdir -p "$HOME/.config"
cp -r "$REPO_ROOT/config/"* "$HOME/.config/"

echo "Configurations installed successfully."
