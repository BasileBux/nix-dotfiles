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

    required property var lock 

    function shutdown() {
        Quickshell.execDetached({
            command: ["systemctl", "poweroff"]
        });
    }
    function reboot() {
        Quickshell.execDetached({
            command: ["systemctl", "reboot"]
        });
    }
    function logout() {
        Quickshell.execDetached({
            command: ["loginctl", "terminate-user", "$USER"]
        });
    }
    function lockScreen() {
        lock.locked = true;
    }



    focus: true
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            popup.collapse();
            lockFocusGrab.active = false;
            return;
        }
        if (event.key === Qt.Key_S) {
            shutdown();
            return;
        }
        if (event.key === Qt.Key_R) {
            reboot();
            return;
        }
        if (event.key === Qt.Key_O) {
            logout();
            return;
        }
        if (event.key === Qt.Key_L) {
            lockScreen();
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
            exec: root.shutdown
        }
        LockItem {
            iconSource: "../icons/reboot.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            exec: root.reboot
        }
        LockItem {
            iconSource: "../icons/logout.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            exec: root.logout
        }
        LockItem {
            iconSource: "../icons/lock.svg"
            scaleFactor: layout.scaleFactor
            iconColor: Globals.theme.foreground
            hoverColor: Globals.theme.accent2
            exec: root.lockScreen
        }
    }
}
