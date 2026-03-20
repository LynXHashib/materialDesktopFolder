// shell.qml — Material Home Folder for Hyprland + QuickShell (latest Arch)
// Run: qs -p ~/.config/quickshell/materialHomeFolder/

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

ShellRoot {
    id: rootShell

    // ─── DMS color integration ────────────────────────────────────────
    // FileView.text is a FUNCTION (text()), not a bindable property.
    // The correct pattern is:
    //   - blockLoading: true  → file is loaded synchronously before windows open
    //   - watchChanges: true  → inotify watch
    //   - onFileChanged: reload() → re-read on disk change (DMS wallpaper switch)
    //   - onLoaded: parseColors() → called after each successful load/reload
    property var _raw: null

    function parseColors() {
        try {
            var t = colorFile.text().trim()
            if (t.length === 0 || t[0] !== "{") {
                retryTimer.restart()
                return
            }
            var obj = JSON.parse(t)
            var c = obj["colors"]
            if (c) {
                rootShell._raw = c["dark"] ?? c["light"] ?? null
            } else {
                rootShell._raw = obj["dark"] ?? obj["light"] ?? obj ?? null
            }
        } catch(e) {
            console.log("DMS color parse error: " + e)
            retryTimer.restart()
        }
    }

    FileView {
        id: colorFile
        path: "/home/hashib/.cache/DankMaterialShell/dms-colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded:      rootShell.parseColors()
        onLoadFailed:  retryTimer.restart()
    }

    Timer {
        id: retryTimer
        interval: 800
        repeat: false
        onTriggered: colorFile.reload()
    }

    // ── Color tokens ─────────────────────────────────────────────────
    readonly property color colBackground:         _raw ? _raw["background"]                : "#171216"
    readonly property color colSurface:            _raw ? _raw["surface"]                   : "#171216"
    readonly property color colSurfaceVariant:     _raw ? _raw["surface_variant"]           : "#4e444b"
    readonly property color colSurfaceBright:      _raw ? _raw["surface_bright"]            : "#3f373c"
    readonly property color colSurfaceContainer:   _raw ? _raw["surface_container"]         : "#171216"
    readonly property color colSurfaceContLow:     _raw ? _raw["surface_container_low"]     : "#201a1e"
    readonly property color colSurfaceContHigh:    _raw ? _raw["surface_container_high"]    : "#241e22"
    readonly property color colSurfaceContHighest: _raw ? _raw["surface_container_highest"] : "#2f282d"
    readonly property color colPrimary:            _raw ? _raw["primary"]                   : "#f3b3e4"
    readonly property color colPrimaryContainer:   _raw ? _raw["primary_container"]         : "#66355f"
    readonly property color colOnPrimary:          _raw ? _raw["on_primary"]                : "#4d1f47"
    readonly property color colOnSurface:          _raw ? _raw["on_surface"]                : "#ecdfe5"
    readonly property color colOnSurfaceVariant:   _raw ? _raw["on_surface_variant"]        : "#d1c2cb"
    readonly property color colOutline:            _raw ? _raw["outline"]                   : "#9a8d95"
    readonly property color colOutlineVariant:     _raw ? _raw["outline_variant"]           : "#4e444b"
    readonly property color colSecondary:          _raw ? _raw["secondary"]                 : "#dbbed2"
    readonly property color colSecondaryContainer: _raw ? _raw["secondary_container"]       : "#554050"
    readonly property color colTertiary:           _raw ? _raw["tertiary"]                  : "#f5b9a5"

    // ─── Global folder state ──────────────────────────────────────────
    QtObject {
        id: folderState
        property real folderX: 120
        property real folderY: 160
        // 0=closed  1=opening  2=open  3=closing
        property int phase: 0
        readonly property bool showPopup: phase === 1 || phase === 2 || phase === 3
        function open()  { if (phase === 0) phase = 1 }
        function close() { if (phase === 2) phase = 3 }
    }

    // ─── WINDOW 1: Circle — WlrLayer.Bottom ──────────────────────────
    PanelWindow {
        id: circleWin
        screen: Quickshell.screens[0]
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        implicitWidth:  screen.width
        implicitHeight: screen.height

        Item {
            id: circleHit
            x: folderState.folderX - 55
            y: folderState.folderY - 55
            width: 110; height: 130
        }
        mask: Region { Region { item: circleHit } }

        FolderCircle {
            anchors.fill: parent
            state_:  folderState
            screenW: circleWin.screen.width
            screenH: circleWin.screen.height
            theme:   rootShell
        }
    }

    // ─── WINDOW 2: Popup — WlrLayer.Top ──────────────────────────────
    PanelWindow {
        id: popupWin
        screen: Quickshell.screens[0]
        color: "transparent"
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        visible: folderState.showPopup
        implicitWidth:  screen.width
        implicitHeight: screen.height

        MouseArea {
            anchors.fill: parent
            onClicked: folderState.close()
        }

        FolderPopup {
            anchors.fill: parent
            state_:  folderState
            screenW: popupWin.screen.width
            screenH: popupWin.screen.height
            theme:   rootShell
        }
    }
}
