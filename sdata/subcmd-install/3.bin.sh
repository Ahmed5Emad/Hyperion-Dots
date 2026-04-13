#!/usr/bin/env bash

# Step 3: Install custom binaries
echo "Installing custom binaries..."

mkdir -p "$HOME/.local/bin"
cp "$REPO_ROOT/bin/hyprtheme" "$HOME/.local/bin/hyprtheme"
chmod +x "$HOME/.local/bin/hyprtheme"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Warning: ~/.local/bin is not in your PATH. Add it to your shell config."
fi

echo "hyprtheme command installed. Use it to download more themes!"
