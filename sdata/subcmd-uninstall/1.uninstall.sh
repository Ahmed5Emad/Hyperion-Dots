#!/usr/bin/env bash

# Step 1: Uninstall Configuration Files
echo "Uninstalling configurations..."

rm -rf "$HOME/.config/hypr"
rm -rf "$HOME/.config/quickshell"
rm -rf "$HOME/.config/matugen"
rm -f "$HOME/.local/bin/hyprtheme"

echo "Configurations uninstalled successfully."
