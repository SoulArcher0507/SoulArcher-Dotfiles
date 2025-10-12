import QtQuick 
import QtQuick.Controls 
import Quickshell 
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io

FreezeScreen {
    id: root
    visible: false

    property var activeScreen: null

    Connections {
        target: Hyprland
        enabled: activeScreen === null

        function onFocusedMonitorChanged() {
            const monitor = Hyprland.focusedMonitor
            if(!monitor) return

            for (const screen of Quickshell.screens) {
                if (screen.name === monitor.name) {
                    activeScreen = screen
                }
            }
        }
    }

    targetScreen: activeScreen

    property var hyprlandMonitor: Hyprland.focusedMonitor
    property string tempPath

    property string mode: "region"

    Shortcut {
        sequence: "Escape"
        onActivated: Qt.quit()
    }
 
    Timer {
        id: showTimer
        interval: 50
        running: false
        repeat: false
        onTriggered: root.visible = true
    }
 
    Component.onCompleted: {
        const timestamp = Date.now()
        const path = Quickshell.cachePath(`screenshot-${timestamp}.png`)
        tempPath = path
        Quickshell.execDetached(["grim", path])
        showTimer.start()
    }

    Process {
        id: screenshotProcess
        running: false

        onExited: () => {
            Qt.quit()
        }

        stdout: StdioCollector {
            onStreamFinished: console.log(this.text)
        }
        stderr: StdioCollector {
            onStreamFinished: console.log(this.text)
        }

    }

    function saveScreenshot(x, y, width, height) {
        const scale = hyprlandMonitor.scale
        const scaledX = Math.round((x + root.hyprlandMonitor.x) * scale)
        const scaledY = Math.round((y + root.hyprlandMonitor.y) * scale)
        const scaledWidth = Math.round(width * scale)
        const scaledHeight = Math.round(height * scale)

        const picturesDir = Quickshell.env("XDG_PICTURES_DIR") || (Quickshell.env("HOME") + "/Pictures/Screenshots")

        const now = new Date()
        const timestamp = Qt.formatDateTime(now, "yyyy-MM-dd_hh-mm-ss")

        const outputPath = `${picturesDir}/screenshot-${timestamp}.png`

        screenshotProcess.command = ["sh", "-c",
            `magick "${tempPath}" -crop ${scaledWidth}x${scaledHeight}+${scaledX}+${scaledY} "${outputPath}" && ` +
            `wl-copy < "${outputPath}" && ` +
            `rm "${tempPath}"`
        ]

        screenshotProcess.running = true
        root.visible = false
    }

    RegionSelector {
        visible: mode === "region"
        id: regionSelector
        anchors.fill: parent
 
        dimOpacity: 0.6
        borderRadius: 10.0
        outlineThickness: 2.0
 
        onRegionSelected: (x, y, width, height) => {
            saveScreenshot(x, y, width, height)
        }
    }
 
    WindowSelector {
        visible: mode === "window"
        id: windowSelector
        anchors.fill: parent
 
        monitor: root.hyprlandMonitor
        dimOpacity: 0.6
        borderRadius: 10.0
        outlineThickness: 2.0
 
        onRegionSelected: (x, y, width, height) => {
            saveScreenshot(x, y, width, height)
        }
    }
 
    WrapperRectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

        color: Qt.rgba(0.1, 0.1, 0.1, 0.8)
        radius: 12
        margin: 8
 
        Row {
            id: buttonRow
            spacing: 8
 
            Repeater {
                model: [
                    { mode: "region", icon: "region" },
                    { mode: "window", icon: "window" },
                    { mode: "screen", icon: "screen" }
                ]
 
                Button {
                    id: modeButton
                    implicitWidth: 48
                    implicitHeight: 48

                    background: Rectangle {
                        radius: 8
                        color: {
                            if(mode === modelData.mode) return Qt.rgba(0.3, 0.4, 0.7, 0.5)
                            if (modeButton.hovered) return Qt.rgba(0.4, 0.4, 0.4, 0.5)

                            return Qt.rgba(0.3, 0.3, 0.35, 0.5)
                        }

                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        Image {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: Quickshell.shellPath(`icons/${modelData.icon}.svg`)
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    onClicked: {
                        root.mode = modelData.mode
                        if (modelData.mode === "screen") {
                            saveScreenshot(0, 0, root.targetScreen.width, root.targetScreen.height)
                        }
                    }
                }
            }
        }
    }
}
