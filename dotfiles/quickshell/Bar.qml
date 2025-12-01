import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import "paths" as Paths
import "barParts" as BarParts

PanelWindow {
    id: root
    color: "transparent"
    implicitWidth: Globals.barWidth
    exclusiveZone: Globals.barWidth - Globals.padding

    anchors {
        top: true
        right: true
        bottom: true
    }

    required property var lock

    property var focusGrab: focusGrab

    property int padding: Globals.padding
    property int radius: Globals.radius
    property int spacing: Globals.spacing
    property color popupColor: Globals.theme.background

    property var popups: [bot.lockPopup, bot.clockPopup, bot.batteryPopup, bot.wifiPopup, bot.bluetoothPopup, bot.audioPopup]

    property var collapseAllBut: name => {
        for (var i = 0; i < root.popups.length; i++) {
            if (root.popups[i].name !== name) {
                root.popups[i].collapse();
            }
        }
    }

    Item {
        id: keyboardBinds
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape || (event.key === Qt.Key_BracketLeft && (event.modifiers & Qt.ControlModifier))) {
                root.popups.forEach(function (popup) {
                    popup.collapse();
                });
                focusGrab.active = false;
            }
        }
    }

    Paths.Bar {}

    ColumnLayout {
        spacing: 0
        uniformCellSizes: true
        anchors.fill: parent
        Rectangle {
            width: Globals.barWidth - 2 * Globals.padding
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Globals.barExtrema * 2
            Layout.fillHeight: true
            color: "transparent"
            BarParts.Top {
                bar: root
            }
        }
        Rectangle {
            width: Globals.barWidth - 2 * Globals.padding
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            color: "transparent"
            BarParts.Mid {
                bar: root
            }
        }
        Rectangle {
            width: Globals.barWidth - 2 * Globals.padding
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Globals.barExtrema * 2
            Layout.fillHeight: true
            color: "transparent"
            BarParts.Bot {
                id: bot
                bar: root
            }
        }
    }

    GlobalShortcut {
        name: "toggle"
        onPressed: {
            root.visible = !root.visible;
            root.popups.forEach(function (popup) {
                popup.collapse();
            });
        }
    }
    GlobalShortcut {
        name: "lock"
        onPressed: {
            if (!root.visible)
                return;
            if (bot.lockPopup.shown) {
                bot.lockPopup.collapse();
                lockFocusGrab.active = false;
                return;
            }
            bot.lockPopup.show();
            lockFocusGrab.active = true;
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root, bot.clockPopup, bot.batteryPopup, bot.wifiPopup, bot.bluetoothPopup, bot.audioPopup]
        onCleared: {
            root.popups.forEach(function (popup) {
                popup.collapse();
            });
        }
    }

    HyprlandFocusGrab {
        id: lockFocusGrab
        windows: [bot.lockPopup]
        onCleared: {
            bot.lockPopup.collapse();
        }
    }
}
