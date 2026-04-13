#!/usr/bin/env bash

# Step 1: Update Configuration Files
echo "Updating configuration files..."

mkdir -p "$HOME/.config"

# Safe sync using rsync or cp
if command -v rsync >/dev/null 2>&1; then
    rsync -av "$REPO_ROOT/config/" "$HOME/.config/"
else
    cp -rv "$REPO_ROOT/config/"* "$HOME/.config/"
fi

# Update custom binaries
mkdir -p "$HOME/.local/bin"
cp "$REPO_ROOT/bin/hyprtheme" "$HOME/.local/bin/hyprtheme"
chmod +x "$HOME/.local/bin/hyprtheme"

echo "Configurations updated successfully."
