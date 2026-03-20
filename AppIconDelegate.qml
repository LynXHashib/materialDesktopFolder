// AppIconDelegate.qml

import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string appName:    ""
    property string appIcon:    ""
    property string appExec:    ""
    property int    animDelay:  0
    property bool   popupOpen:  false

    // DMS color tokens
    property color colIconBg             // surface_container_highest: #252b2c
    property color colPrimary            // primary: #81d3e0  (teal)
    property color colOnPrimary          // on_primary: #00363d (dark teal for text on primary)
    property color colOnSurface          // on_surface: #dee3e5
    property color colOnSurfaceVariant   // on_surface_variant: #bfc8ca

    signal launched()

    width: 70; height: 90

    // ── Staggered pop-in ─────────────────────────────────────────
    property real enterT: 0.0
    Behavior on enterT {
        SequentialAnimation {
            PauseAnimation  { duration: root.animDelay }
            NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 0.8 }
        }
    }
    onPopupOpenChanged: { enterT = popupOpen ? 1.0 : 0.0 }
    scale:   enterT
    opacity: enterT > 0.01 ? 1 : 0

    // ── App launcher ─────────────────────────────────────────────
    Process {
        id: launcher
        command: ["/bin/sh", "-c", root.appExec]
        running: false
    }

    // ── Icon pill ─────────────────────────────────────────────────
    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0; width: 56; height: 56; radius: 16

        // Idle:   surface_container_highest (#252b2c) — slightly lighter than card
        // Hover:  primary_container tint
        // Press:  primary fill — the teal button color from DMS
        color: pressArea.pressed
               ? Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.28)
               : (hov.containsMouse
                  ? Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.13)
                  : root.colIconBg)
        Behavior on color { ColorAnimation { duration: 110 } }

        scale: pressArea.pressed ? 0.88 : 1.0
        Behavior on scale { SpringAnimation { spring: 9; damping: 0.65 } }

        // outline_variant border on idle
        Rectangle {
            anchors.fill: parent; radius: parent.radius
            color: "transparent"
            border.color: Qt.rgba(
                root.colPrimary.r, root.colPrimary.g, root.colPrimary.b,
                hov.containsMouse ? 0.5 : 0.15
            )
            border.width: 1
            Behavior on border.color { ColorAnimation { duration: 150 } }
        }

        // App icon
        Image {
            id: iconImg
            anchors.fill: parent; anchors.margins: 8
            source: "image://icon/" + root.appIcon
            fillMode: Image.PreserveAspectFit
            smooth: true; mipmap: true
        }

        // Letter fallback — on_primary color so it's readable on the teal press state
        Text {
            anchors.centerIn: parent
            text: root.appName.length > 0 ? root.appName[0].toUpperCase() : "?"
            color: root.colOnSurface
            font.pixelSize: 22; font.family: "sans-serif"; font.weight: Font.Bold
            visible: iconImg.status !== Image.Ready
        }

        // Ripple — primary teal, matches DMS button ripples
        Rectangle {
            id: ripple
            anchors.centerIn: parent
            width: rippleOn ? 70 : 0; height: width; radius: width / 2
            color: Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.35)
            opacity: rippleOn ? 0 : 0
            property bool rippleOn: false
            Behavior on width   { NumberAnimation { duration: 280; easing.type: Easing.OutQuad } }
        }

        HoverHandler { id: hov }

        MouseArea {
            id: pressArea
            anchors.fill: parent
            onPressed: {
                ripple.rippleOn = false
                ripple.width = 0; ripple.opacity = 0.6
                ripple.rippleOn = true
            }
            onClicked: {
                launcher.running = true
                root.launched()
            }
        }
    }

    // ── App name label
    // on_surface_variant: slightly dimmed, matches DMS subtitle text (#bfc8ca)
    Text {
        anchors.top: pill.bottom; anchors.topMargin: 6
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        text: root.appName
        color: root.colOnSurfaceVariant
        font.pixelSize: 11; font.family: "sans-serif"
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }
}
