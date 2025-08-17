import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ".."

Item {
    id: root
    anchors.fill: parent

    readonly property var shutdownCommand: ["systemctl", "poweroff"]
    readonly property var rebootCommand: ["systemctl", "reboot"]
    readonly property var logoutCommand: ["loginctl", "terminate-user", "$USER"]
    readonly property var lockCommand: ["hyprlock"]

    focus: true
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            popup.collapse();
            focusGrab.active = false;
            return;
        }
        if (event.key === Qt.Key_S) {
            Quickshell.execDetached({
                command: shutdownCommand,
            });
            return;
        }
        if (event.key === Qt.Key_R) {
            Quickshell.execDetached({
                command: rebootCommand,
            });
            return;
        }
        if (event.key === Qt.Key_O) {
            Quickshell.execDetached({
                command: logoutCommand,
            });
            return;
        }
        if (event.key === Qt.Key_L) {
            Quickshell.execDetached({
                command: lockCommand,
            });
            return;
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: Globals.spacing
        uniformCellSizes: true
        property real scaleFactor: 0.5

        LockItem {
            iconSource: "../icons/shutdown.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            command: shutdownCommand
        }
        LockItem {
            iconSource: "../icons/reboot.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            command: rebootCommand
        }
        LockItem {
            iconSource: "../icons/logout.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            command: logoutCommand
        }
        LockItem {
            iconSource: "../icons/lock.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            command: lockCommand
        }
    }
}
