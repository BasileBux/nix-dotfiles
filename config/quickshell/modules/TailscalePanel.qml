import Quickshell
import QtQuick
import ".."

// Floating panel instead of a bar popup: survives the native file dialogs
// (no HyprlandFocusGrab fighting them). Stays open until closed via the
// network popup button or Esc.
Window {
    id: root

    readonly property int panelWidth: 380
    readonly property int panelHeight: 340
    readonly property int screenMargin: 8

    width: panelWidth
    height: panelHeight
    minimumWidth: panelWidth
    maximumWidth: panelWidth
    minimumHeight: panelHeight
    maximumHeight: panelHeight
    // matched by the hyprland float rule
    title: "Tailscale"
    flags: Qt.Dialog | Qt.FramelessWindowHint
    color: "transparent"
    visible: false

    // bar icon slot, used to position the panel on open
    property Item anchorItem: null

    readonly property bool pickersOpen: content.pickersOpen

    onVisibleChanged: {
        if (!visible) return;
        var iconY = anchorItem ? anchorItem.mapToItem(null, 0, 0).y : 100;
        root.x = (root.screen?.width ?? 1920) - panelWidth - Globals.barWidth - screenMargin;
        root.y = Math.max(screenMargin, Math.min(iconY - 10, (root.screen?.height ?? 1080) - panelHeight - screenMargin));
    }

    function toggle() {
        visible ? hide() : show();
    }
    function show() {
        Globals.playSound(Globals.sounds.click);
        visible = true;
        requestActivate();
    }
    function hide() {
        visible = false;
    }

    Shortcut {
        sequences: ["Esc"]
        enabled: root.visible
        onActivated: root.hide()
    }

    Rectangle {
        anchors.fill: parent
        // hyprland rounds the corners
        color: Globals.theme.background
    }

    TailscalePopup {
        id: content
        popupShown: root.visible
        anchors.fill: parent
        anchors.margins: Globals.radius * 2
    }
}
