#!/usr/bin/env bash

# branch_themes.sh: Converts local theme folders into independent git branches
# for the Hypr-Dots repository.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
THEME_SRC="$HOME/.config/themes"
ICON_SRC="$HOME/.local/share/icons"

cd "$REPO_ROOT" || exit 1

for theme_path in "$THEME_SRC"/*; do
    [ -d "$theme_path" ] || continue
    theme_name=$(basename "$theme_path")
    branch_name="theme/${theme_name// /-}" # Replace spaces with dashes
    
    echo "-------------------------------------------------------"
    echo "Processing Theme: $theme_name -> Branch: $branch_name"
    
    # Create a new orphan branch
    git checkout --orphan "$branch_name"
    git rm -rf . # Clear the branch
    
    # Copy theme files
    cp -r "$theme_path/"* .
    
    # Bundle icons if found in theme.json
    if [ -f "theme.json" ]; then
        icon_name=$(jq -r '.icons // empty' "theme.json")
        if [ -n "$icon_name" ] && [ -d "$ICON_SRC/$icon_name" ]; then
            echo "Bundling icons: $icon_name"
            tar -czf "icons.tar.gz" -C "$ICON_SRC" "$icon_name"
        fi
    fi
    
    # Create a basic README if missing
    if [ ! -f "README.md" ]; then
        cat > README.md << EOF
# $theme_name Theme

Part of the Hypr-Dots repository.

## Installation
Download this theme via the \`hyprtheme\` command in the main branch.

## Icons
Bundled in \`icons.tar.gz\`.
EOF
    fi
    
    # Commit
    git add .
    git commit -m "Add theme: $theme_name"
    
    echo "Theme branch '$branch_name' created."
done

# Switch back to main
git checkout main
echo "All theme branches processed. Back on 'main'."
