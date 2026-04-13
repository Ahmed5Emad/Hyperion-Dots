import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

/**
 * Thumbnail image. It currently generates to the right place at the right size, but does not handle metadata/maintenance on modification.
 * See Freedesktop's spec: https://specifications.freedesktop.org/thumbnail-spec/thumbnail-spec-latest.html
 */
StyledImage {
    id: root

    property bool generateThumbnail: true
    required property string sourcePath
    property string thumbnailSizeName: Images.thumbnailSizeNameForDimensions(sourceSize.width, sourceSize.height)
    property string thumbnailPath: {
        if (sourcePath.length == 0) return "";
        
        let rawPath = FileUtils.trimFileProtocol(sourcePath);
        try { rawPath = decodeURIComponent(rawPath); } catch (e) {}
        
        const encodedPath = rawPath.split("/").map(part => encodeURIComponent(part)).join("/");
        const uri = "file://" + (encodedPath.startsWith("/") ? "" : "/") + encodedPath;
        const md5Hash = Qt.md5(uri);
        
        const cachePath = FileUtils.trimFileProtocol(Directories.genericCache);
        return `file://${cachePath}/thumbnails/${thumbnailSizeName}/${md5Hash}.png`;
    }
    
    // Default to showing the original image if the thumbnail isn't there yet
    source: {
        const thumbRaw = FileUtils.trimFileProtocol(thumbnailPath);
        // This is a bit of a hack as we can't easily check file existence synchronously in QML
        // but we'll try to use the thumb first, and rely on StyledImage fallbacks
        return thumbnailPath;
    }
    
    fallbacks: [
        sourcePath.startsWith("file://") ? sourcePath : "file://" + sourcePath
    ]

    asynchronous: true
    smooth: true
    mipmap: false

    opacity: status === Image.Ready ? 1 : 0
    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    onSourceSizeChanged: {
        if (!root.generateThumbnail) return;
        thumbnailGeneration.running = false;
        thumbnailGeneration.running = true;
    }
    
    Process {
        id: thumbnailGeneration
        command: {
            const maxSize = Images.thumbnailSizes[root.thumbnailSizeName];
            let cleanSourcePath = FileUtils.trimFileProtocol(root.sourcePath);
            try { cleanSourcePath = decodeURIComponent(cleanSourcePath); } catch (e) {}
            
            const cleanThumbPath = FileUtils.trimFileProtocol(root.thumbnailPath);
            
            return ["bash", "-c", 
                `mkdir -p "$(dirname "${cleanThumbPath}")" && [ -f "${cleanThumbPath}" ] && exit 0 || { magick "${cleanSourcePath}" -resize ${maxSize}x${maxSize} "${cleanThumbPath}" && exit 1; }`
            ]
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 1) {
                // Refresh if we just created the thumb
                const oldSource = root.source;
                root.source = "";
                root.source = oldSource;
            }
        }
    }
}
