import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    property string pendingDir: ""

    Timer {
        id: transitionTimer
        interval: 100
        repeat: false
        onTriggered: {
            Wallpapers.setDirectory(root.pendingDir);
            GlobalStates.wallpaperSelectorOpen = true;
        }
    }

    PanelWindow {
        id: window
        visible: GlobalStates.themeSelectorOpen

        WlrLayershell.namespace: "quickshell:themeselector"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: GlobalStates.themeSelectorOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
        }
        margins {
            top: Appearance.sizes.hyprlandGapsOut + (Config.options.bar.vertical ? 0 : Appearance.sizes.barHeight)
            bottom: Appearance.sizes.hyprlandGapsOut
            left: Appearance.sizes.hyprlandGapsOut
        }
        
        width: Appearance.sizes.sidebarWidth

        Connections {
            target: GlobalStates
            function onThemeSelectorOpenChanged() {
                if (GlobalStates.themeSelectorOpen) {
                    GlobalFocusGrab.addDismissable(window);
                    listView.forceActiveFocus();
                } else {
                    GlobalFocusGrab.dismiss();
                }
            }
        }

        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                GlobalStates.themeSelectorOpen = false;
            }
        }

        Rectangle {
            id: container
            anchors.fill: parent
            color: Appearance.colors.colBackgroundSurfaceContainer
            radius: Appearance.rounding.windowRounding
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: container.width
                    height: container.height
                    radius: container.radius
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 0

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: ThemeManager.themes
                    keyNavigationWraps: true
                    spacing: 15
                    clip: true
                    
                    topMargin: 10
                    bottomMargin: 10
                    
                    highlight: Rectangle {
                        color: Qt.rgba(1, 1, 1, 0.05)
                        border.width: 2
                        border.color: Appearance.colors.colPrimary
                        radius: 12
                        z: 10
                    }
                    highlightMoveDuration: 150

                    delegate: Item {
                        id: themeCard
                        width: listView.width
                        height: 200
                        
                        readonly property string themeName: modelData ? modelData : ""
                        readonly property bool isCurrent: ListView.isCurrentItem
                        
                        Rectangle {
                            id: cardRoot
                            anchors.fill: parent
                            radius: 12
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.1)
                            
                            Item {
                                anchors.fill: parent
                                anchors.margins: 1
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: cardRoot.width - 2
                                        height: cardRoot.height - 2
                                        radius: cardRoot.radius
                                    }
                                }

                                StyledImage {
                                    id: coverImage
                                    anchors.fill: parent
                                    source: ThemeManager.themePreviews[themeName] || ""
                                    fillMode: Image.PreserveAspectCrop
                                    opacity: (rippleButton.hovered || themeCard.isCurrent) ? 1.0 : 0.7
                                    asynchronous: true
                                    cache: true
                                    sourceSize.width: parent.width * 1.2
                                    sourceSize.height: parent.height * 1.2
                                    
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    gradient: Gradient {
                                        GradientStop { position: 0.3; color: "transparent" }
                                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.95) }
                                    }
                                }
                            }

                            RippleButton {
                                id: rippleButton
                                anchors.fill: parent
                                buttonRadius: cardRoot.radius
                                colBackground: "transparent"
                                activeFocusOnTab: false

                                onClicked: {
                                    if (!themeName) return;
                                    root.pendingDir = FileUtils.trimFileProtocol(Directories.configPath) + "/themes/" + themeName + "/wallpapers";
                                    GlobalStates.themeSelectorOpen = false;
                                    transitionTimer.start();
                                }

                                RowLayout {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 20
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredWidth: 4
                                        Layout.preferredHeight: 22
                                        radius: 2
                                        color: Appearance.colors.colPrimary
                                        visible: themeCard.isCurrent
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: themeName
                                        font.pixelSize: Appearance.font.pixelSize.huge
                                        font.weight: themeCard.isCurrent ? Font.Bold : Font.DemiBold
                                        color: "white"
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            GlobalStates.themeSelectorOpen = false;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            const currentTheme = ThemeManager.themes[listView.currentIndex];
                            if (currentTheme) {
                                root.pendingDir = FileUtils.trimFileProtocol(Directories.configPath) + "/themes/" + currentTheme + "/wallpapers";
                                GlobalStates.themeSelectorOpen = false;
                                transitionTimer.start();
                            }
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "themeselector"
        function toggle() { GlobalStates.themeSelectorOpen = !GlobalStates.themeSelectorOpen; }
        function open() { GlobalStates.themeSelectorOpen = true; }
        function close() { GlobalStates.themeSelectorOpen = false; }
    }

    GlobalShortcut {
        name: "themeSelectorToggle"
        description: "Toggle theme selector"
        onPressed: {
            GlobalStates.themeSelectorOpen = !GlobalStates.themeSelectorOpen;
        }
    }
}
