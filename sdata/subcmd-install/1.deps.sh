#!/usr/bin/env bash

# Step 1: Install Dependencies (Arch Linux)
echo "Installing dependencies..."

# Comprehensive list of dependencies from your setup
PKGS=(
    # Hyprland and core ecosystem
    hyprland hypridle hyprlock hyprpicker hyprsunset hyprshot
    
    # Core tools
    quickshell kitty starship matugen waybar
    jq fzf bc coreutils cliphist cmake curl wget ripgrep rsync eza fish
    
    # Audio & Media
    cava pavucontrol-qt playerctl songrec
    
    # Screen & Brightness
    brightnessctl ddcutil slurp swappy tesseract tesseract-data-eng wf-recorder
    
    # System & Integration
    wl-clipboard bluedevil gnome-keyring networkmanager plasma-nm
    polkit-kde-agent dolphin systemsettings upower wtype ydotool wlogout
    xdg-user-dirs glib2 imagemagick translate-shell libqalculate uv
    
    # Portals
    xdg-desktop-portal xdg-desktop-portal-kde xdg-desktop-portal-gtk xdg-desktop-portal-hyprland
    
    # Qt6 & KDE Frameworks
    qt6-base qt6-declarative qt6-5compat qt6-svg qt6-wayland kirigami kdialog syntax-highlighting
    
  
)

echo "The following packages will be installed:"
echo "${PKGS[@]}"

# Use yay if available, otherwise pacman
if command -v yay >/dev/null 2>&1; then
    yay -S --needed "${PKGS[@]}"
else
    sudo pacman -S --needed "${PKGS[@]}"
fi
