# Hyperion-Dots

Hyperion-Dots is a highly optimized, modular, and dynamic dotfiles setup for Hyprland. It builds upon excellent community foundations to deliver a polished, performant, and fully integrated desktop experience.

## Acknowledgements

This project is deeply inspired by and utilizes code from the following amazing projects:
- **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)**: The core Quickshell architecture, UI components, and initial concepts heavily rely on end-4's brilliant work.
- **[HyDe Themes](https://github.com/Hyde-project/hyde)**: Many of the beautifully curated themes and configurations were sourced and adapted from the HyDe (Hyprland Dots) ecosystem.

## Key Changes & Fixes

Hyperion-Dots introduces several major structural, performance, and UX improvements over its upstream inspirations:

### Architecture & Installation
- **Modular Installer System**: A completely revamped setup script featuring `install`, `update`, and `uninstall` subcommands for safe and organized configuration management.
- **Orphaned Theme Branches**: To keep the `main` repository incredibly lightweight, all 23+ themes have been isolated into their own independent git branches.
- **Bundled Assets**: Theme branches now come with their specific icon packs bundled directly (`icons.tar.gz`), eliminating the need to download massive icon repositories separately.
- **`hyprtheme` TUI**: A globally accessible, interactive Terminal User Interface (powered by `fzf`) that dynamically fetches available themes from GitHub, downloads them, extracts their icons, and applies them instantly.

### UI/UX Improvements (Theme Manager)
- **Redesigned Theme Selector**: The Quickshell Theme Selector was completely rewritten to match the sleek horizontal layout of the Game Launcher. It features a wider list, smooth sliding highlights (`highlightMoveDuration`), modern typography, and a native "slide-in" animation handled directly by Hyprland.
- **Extreme Performance Optimizations**: Removed expensive real-time `OpacityMask` layers and shadows from the theme and wallpaper grids. Implemented image caching and `sourceSize` constraints to eliminate memory hogging and scrolling lag.
- **Lightning Fast Previews**: The theme preview generator was optimized to avoid slow recursive searches, prioritizing specific logo files for near-instant load times.

### Terminal & Theming Fixes
- **Robust Kitty Theme Parsing**: The theme applier now features a highly resilient parser that perfectly handles inconsistent spacing, tabs, and comments in `.theme` files, ensuring terminal colors never randomly break or default to white.
- **Flawless Terminal Synchronization**: Fixed a major bug where the dynamic color generator would overwrite curated terminal backgrounds (causing solid, "washed-out" colors and destroying transparency). The system now intelligently extracts ANSI colors from curated themes and broadcasts *only* the palette updates to open terminals. Themes like *LimeFrenzy* and *Red_Stone* retain their intended transparency!
- **Starship Prompt Integration**: Completely overhauled `starship.toml`. Removed hardcoded, ugly background blocks and fixed invalid ANSI color syntax. The prompt is now fully transparent and dynamically absorbs the exact accent colors of whatever theme you apply.
- **Heroic Launcher Fix**: Ensured the Heroic Games Launcher properly receives Material You color updates when switching themes without causing terminal color conflicts.

## Installation

To install Hyperion-Dots, clone the repository and run the setup script:

```bash
git clone https://github.com/Ahmed5Emad/Hyperion-Dots.git ~/Hyperion-Dots
cd ~/Hyperion-Dots
./setup install
```

Once installed, simply type `hyprtheme` in your terminal to browse, download, and apply themes!