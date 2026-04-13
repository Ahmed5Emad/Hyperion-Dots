pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

/**
 * Handles detection and application of curated theme packs.
 */
Singleton {
    id: root

    readonly property string themesDir: FileUtils.trimFileProtocol(Directories.configPath) + "/themes"
    property list<string> themes: []
    property var themePreviews: ({})

    function updateThemesList() {
        const newThemes = [];
        for (let i = 0; i < folderModel.count; i++) {
            if (folderModel.isFolder(i)) {
                newThemes.push(folderModel.get(i, "fileName"));
            }
        }
        root.themes = newThemes;
        
        // Find one preview image for each theme - optimized
        previewProc.command = ["bash", "-c", `
            for d in "${themesDir}"/*/; do
                [ -d "$d" ] || continue
                name=$(basename "$d")
                img=""
                if [ -f "$d/logo/logo_last.png" ]; then
                    img="$d/logo/logo_last.png"
                elif [ -f "$d/logo/logo.png" ]; then
                    img="$d/logo/logo.png"
                else
                    img=$(ls "$d/wallpapers/"* 2>/dev/null | head -n 1)
                fi
                echo "$name|$img"
            done
        `];
        previewProc.running = true;
    }

    Process {
        id: previewProc
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n');
                const previews = {};
                lines.forEach(line => {
                    const parts = line.split('|');
                    if (parts.length === 2 && parts[1]) {
                        previews[parts[0]] = "file://" + parts[1];
                    }
                });
                // Re-assigning the whole object to trigger QML property updates
                root.themePreviews = previews;
                console.log("[ThemeManager] Loaded previews for", Object.keys(previews).length, "themes");
            }
        }
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + root.themesDir
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
        onCountChanged: root.updateThemesList()
    }

    Component.onCompleted: root.updateThemesList()

    function getThemeInfo(wallpaperPath) {
        try {
            const normalizedPath = FileUtils.trimFileProtocol(wallpaperPath);
            if (normalizedPath.indexOf(root.themesDir) !== 0) return null;
            const relativePath = normalizedPath.substring(root.themesDir.length + 1);
            const themeName = relativePath.split('/')[0];
            if (!themeName) return null;
            return { name: themeName, path: root.themesDir + "/" + themeName };
        } catch (e) {
            return null;
        }
    }

    function applyThemeForWallpaper(wallpaperPath, darkMode) {
        const info = getThemeInfo(wallpaperPath);
        if (!info) return false;
        const scriptPath = FileUtils.trimFileProtocol(Directories.scriptPath) + "/colors/apply_curated_theme.sh";
        applyThemeProc.exec([
            scriptPath,
            "--theme-path", info.path,
            "--image", FileUtils.trimFileProtocol(wallpaperPath),
            "--mode", (darkMode ? "dark" : "light")
        ]);
        return true;
    }

    Process {
        id: applyThemeProc
        onExited: (exitCode) => {
            if (exitCode === 0) {
                MaterialThemeLoader.reapplyTheme();
                // Refresh previews to show the new logo_last.png
                root.updateThemesList();
            }
        }
    }
}
