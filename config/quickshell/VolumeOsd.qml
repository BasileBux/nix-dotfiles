import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import "services" as Services
import "widgets" as Widgets

// macOS-style volume HUD: speaker icon + percent, top-center, auto-hides.
// Shown by the quickshell:volume-* Hyprland global shortcuts below.
PanelWindow {
    id: root

    readonly property int hideMs: 1200

    function show() {
        visible = true;
        hideTimer.restart();
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    implicitHeight: 120
    implicitWidth: 120
    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "shell:volume-osd"

    anchors {
        bottom: true
    }
    margins {
        // No horizontal anchor: place the window centered manually.
        left: (screen.width - implicitWidth) / 2
        bottom: (screen.height / 5)
    }

    Rectangle {
        anchors.fill: parent

        border.color: Globals.surfaceBorder
        border.width: 1
        color: Globals.surfaceBackground
        // Same rule as the palette: a window-level show/hide never animates.
        opacity: visible ? 1 : 0
        radius: Globals.cardRadius
    }
    Column {
        anchors.centerIn: parent
        spacing: Globals.space2

        Widgets.TintIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Globals.theme.foreground
            height: 36
            name: Services.Audio.muted ? "muted" : "speaker"
            width: 36
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Globals.theme.foreground
            font.family: Globals.theme.fontFamily
            font.features: {
                "tnum": 1
            }
            font.pixelSize: Globals.fonts.title
            font.weight: Font.DemiBold
            text: Services.Audio.muted ? "Muted" : Globals.percent(Services.Audio.volume)
        }
    }
    Timer {
        id: hideTimer

        interval: root.hideMs

        onTriggered: root.visible = false
    }
    GlobalShortcut {
        description: "Raise the volume"

        name: "volume-up"

        onPressed: {
            Services.Audio.adjustVolume(true);
            root.show();
        }
    }
    GlobalShortcut {
        description: "Lower the volume"

        name: "volume-down"

        onPressed: {
            Services.Audio.adjustVolume(false);
            root.show();
        }
    }
    GlobalShortcut {
        description: "Toggle mute"

        name: "volume-mute"

        onPressed: {
            Services.Audio.toggleMute();
            root.show();
        }
    }
}
