// FolderPopup.qml — expanded folder popup (WlrLayer.Top)

import QtQuick
import Quickshell

Item {
    id: root

    required property QtObject state_
    required property real screenW
    required property real screenH
    required property QtObject theme
    readonly property string folderName: "Games"
    readonly property var apps: [{
        "name": "Chess",
        "icon": "gnome-chess",
        "exec": "gnome-chess"
    }, {
        "name": "Lutris",
        "icon": "lutris",
        "exec": "lutris"
    }, {
        "name": "Steam",
        "icon": "steam",
        "exec": "steam"
    }, {
        "name": "Heroic",
        "icon": "heroic-games-launcher",
        "exec": "heroic"
    }, {
        "name": "Bottles",
        "icon": "bottles",
        "exec": "bottles"
    }]
    readonly property int cols: Math.ceil(Math.sqrt(apps.length))
    readonly property int rows: Math.ceil(apps.length / cols)
    readonly property real cardW: cols * 84 + 32
    readonly property real cardH: rows * 92 + 62
    readonly property real pinX: Math.max(cardW / 2 + 16, Math.min(state_.folderX, screenW - cardW / 2 - 16))
    readonly property real pinY: Math.max(cardH / 2 + 16, Math.min(state_.folderY, screenH - cardH / 2 - 16))
    property real visT: 0
    property bool _isOpening: false

    anchors.fill: parent
    onVisTChanged: {
        if (visT >= 0.999 && state_.phase === 1)
            state_.phase = 2;
        else if (visT <= 0.001 && state_.phase === 3)
            state_.phase = 0;
    }

    Connections {
        function onPhaseChanged() {
            if (state_.phase === 1) {
                root._isOpening = true;
                root.visT = 0;
                root.visT = 1;
            } else if (state_.phase === 3) {
                root._isOpening = false;
                root.visT = 0;
            }
        }

        target: state_
    }

    Item {
        id: card

        width: 90 + (root.cardW - 90) * root.visT
        height: 90 + (root.cardH - 90) * root.visT
        x: root.pinX - width / 2
        y: root.pinY - height / 2
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: {
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 45 + (28 - 45) * root.visT
            // surface_bright — matches the elevated DMS widget tone.
            // For pink theme: #3f373c. Reactive to theme changes.
            // 92% opacity so a whisper of the desktop bleeds through.
            color: Qt.rgba(theme.colSurfaceBright.r, theme.colSurfaceBright.g, theme.colSurfaceBright.b, 0.92)

            // Elevation sheen
            Rectangle {
                height: parent.height * 0.4
                radius: parent.radius

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                gradient: Gradient {
                    orientation: Gradient.Vertical

                    GradientStop {
                        position: 0
                        color: Qt.rgba(1, 1, 1, 0.055)
                    }

                    GradientStop {
                        position: 1
                        color: "transparent"
                    }

                }

            }

            // outline_variant border
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: theme.colOutlineVariant
                border.width: 1
                opacity: 0.7
            }

        }

        // Content — fades in during last 40% of expansion
        Item {
            anchors.fill: parent
            opacity: Math.max(0, (root.visT - 0.6) / 0.4)
            visible: opacity > 0.01

            // Title in primary color
            Text {
                id: titleText

                anchors.top: parent.top
                anchors.topMargin: 18
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.folderName
                color: theme.colPrimary
                font.pixelSize: 14
                font.family: "sans-serif"
                font.weight: Font.Medium
            }

            // Primary underline
            Rectangle {
                anchors.top: titleText.bottom
                anchors.topMargin: 3
                anchors.horizontalCenter: parent.horizontalCenter
                width: titleText.implicitWidth + 6
                height: 2
                radius: 1
                color: theme.colPrimary
                opacity: 0.65
            }

            Grid {
                anchors.top: titleText.bottom
                anchors.topMargin: 18
                anchors.horizontalCenter: parent.horizontalCenter
                columns: root.cols
                spacing: 10

                Repeater {
                    model: root.apps

                    delegate: AppIconDelegate {
                        appName: modelData.name
                        appIcon: modelData.icon
                        appExec: modelData.exec
                        animDelay: index * 28
                        popupOpen: state_.phase === 2
                        // surface_variant for pills — slightly lighter than surface_bright,
                        // gives contrast against the card background
                        colIconBg: theme.colSurfaceVariant
                        colPrimary: theme.colPrimary
                        colOnPrimary: theme.colOnPrimary
                        colOnSurface: theme.colOnSurface
                        colOnSurfaceVariant: theme.colOnSurfaceVariant
                        onLaunched: state_.close()
                    }

                }

            }

        }

    }

    Behavior on visT {
        NumberAnimation {
            duration: root._isOpening ? 360 : 260
            easing.type: root._isOpening ? Easing.OutBack : Easing.InCubic
            easing.overshoot: root._isOpening ? 0.5 : 0
        }

    }

}
