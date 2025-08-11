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

    focus: true
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            popup.collapse();
            focusGrab.active = false;
            return;
        }
        if (event.key === Qt.Key_S) {
            shutdownProcess.running = true;
            return;
        }
        if (event.key === Qt.Key_R) {
            rebootProcess.running = true;
            return;
        }
        if (event.key === Qt.Key_O) {
            logoutProcess.running = true;
            return;
        }
        if (event.key === Qt.Key_L) {
            lockProcess.running = true;
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
            process: shutdownProcess
        }
        LockItem {
            iconSource: "../icons/reboot.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            process: rebootProcess
        }
        LockItem {
            iconSource: "../icons/logout.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            process: logoutProcess
        }
        LockItem {
            iconSource: "../icons/lock.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            process: lockProcess
        }
    }

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
        running: false
    }
    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
        running: false
    }
    Process {
        id: logoutProcess
        command: ["loginctl", "terminate-user", "$USER"]
        running: false
    }
    Process {
        id: lockProcess
        command: ["hyprlock"]
        running: false
    }
}
