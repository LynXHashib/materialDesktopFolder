// FolderCircle.qml — draggable collapsed folder circle (WlrLayer.Bottom)

import Quickshell
import QtQuick

Item {
    id: root
    anchors.fill: parent

    required property QtObject state_
    required property real     screenW
    required property real     screenH
    required property QtObject theme

    readonly property string folderName: "Games"
    readonly property var apps: [
        { name: "Chess",    icon: "gnome-chess",           exec: "gnome-chess" },
        { name: "Lutris",   icon: "lutris",                exec: "lutris"      },
        { name: "Steam",    icon: "steam",                 exec: "steam"       },
        { name: "Heroic",   icon: "heroic-games-launcher", exec: "heroic"      },
        { name: "Bottles",  icon: "bottles",               exec: "bottles"     },
    ]

    property real morphT: 0.0
    Behavior on morphT {
        NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
    }
    onMorphTChanged: {
        if (morphT >= 0.999 && state_.phase === 1) state_.phase = 2
    }
    Connections {
        target: state_
        function onPhaseChanged() {
            morphT = (state_.phase === 1 || state_.phase === 2) ? 1.0 : 0.0
        }
    }

    // ── Single full-screen MouseArea — owns the gesture from press ────
    // Hit-tested manually so only circle presses activate drag/open.
    MouseArea {
        id: ma
        anchors.fill: parent
        property bool active:  false
        property bool didDrag: false
        property real startX:  0
        property real startY:  0
        property real offX:    0
        property real offY:    0

        onPressed: (mouse) => {
            if (state_.phase !== 0) return
            var dx = mouse.x - state_.folderX
            var dy = mouse.y - state_.folderY
            if (dx*dx + dy*dy > 48*48) return
            active = true; didDrag = false
            startX = mouse.x; startY = mouse.y
            offX = dx; offY = dy
        }
        onPositionChanged: (mouse) => {
            if (!active) return
            if (Math.abs(mouse.x - startX) > 6 || Math.abs(mouse.y - startY) > 6)
                didDrag = true
            state_.folderX = Math.max(50, Math.min(root.screenW - 50, mouse.x - offX))
            state_.folderY = Math.max(50, Math.min(root.screenH - 50, mouse.y - offY))
        }
        onReleased: {
            if (!active) return
            active = false
            if (!didDrag) state_.open()
        }
    }

    // ── Circle visual ─────────────────────────────────────────────────
    Item {
        x: state_.folderX - 45
        y: state_.folderY - 45
        width: 90; height: 115

        Rectangle {
            id: disc
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0; width: 90; height: 90; radius: 45
            scale:   1.0 - root.morphT * 0.25
            opacity: 1.0 - root.morphT

            // surface_bright — the highest natural surface elevation in Material You.
            // For the current pink theme: #3f373c — a warm muted tone that reads as
            // "elevated" vs the near-black background, matching the DMS widget feel.
            // Reactive: updates immediately when DMS changes the theme.
            color: theme.colSurfaceBright

            // primary_container inner tint — adds the accent hue into the circle
            Rectangle {
                anchors.fill: parent; radius: parent.radius
                color: Qt.rgba(
                    theme.colPrimaryContainer.r,
                    theme.colPrimaryContainer.g,
                    theme.colPrimaryContainer.b,
                    0.25
                )
            }

            // Clean outline_variant border — 1px, no shadow
            Rectangle {
                anchors.fill: parent; radius: parent.radius
                color: "transparent"
                border.color: theme.colOutlineVariant
                border.width: 1; opacity: 0.9
            }

            // Icon grid preview
            Grid {
                anchors.centerIn: parent
                columns: 3; spacing: 4
                Repeater {
                    model: Math.min(root.apps.length, 6)
                    delegate: Rectangle {
                        width: 18; height: 18; radius: 5
                        color: Qt.rgba(
                            theme.colPrimaryContainer.r,
                            theme.colPrimaryContainer.g,
                            theme.colPrimaryContainer.b,
                            0.55
                        )
                        Image {
                            anchors.fill: parent; anchors.margins: 2
                            source: "image://icon/" + root.apps[index].icon
                            fillMode: Image.PreserveAspectFit; smooth: true
                        }
                    }
                }
            }

            // Hover ring in primary color
            Rectangle {
                anchors.fill: parent; radius: parent.radius
                color: "transparent"
                border.color: theme.colPrimary; border.width: 2
                opacity: {
                    if (root.morphT > 0.05) return 0
                    var dx = ma.mouseX - state_.folderX
                    var dy = ma.mouseY - state_.folderY
                    return (dx*dx + dy*dy < 50*50) ? 0.75 : 0
                }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }

        // Label
        Text {
            anchors.top: disc.bottom; anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.folderName
            color: theme.colOnSurfaceVariant
            font.pixelSize: 12; font.family: "sans-serif"; font.weight: Font.Medium
            opacity: 1.0 - root.morphT
            style: Text.Outline; styleColor: Qt.rgba(0,0,0,0.6)
        }
    }
}
