import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Controls
import ".."

Item {
    id: root
    anchors.fill: parent

    required property int popupYpos
    required property int popupHeight
    readonly property alias popup: popup

    Button {
        id: bluetoothIcon
        anchors.fill: parent
        background: Rectangle {
            color: "transparent"
        }
        icon.source: "../icons/bluetooth.svg"
        icon.width: parent.width * 0.8
        icon.height: parent.width * 0.8
        icon.color: Globals.theme.foreground
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
        }
        onEntered: {
            bluetoothIcon.icon.color = Globals.theme.accent2;
        }
        onExited: {
            bluetoothIcon.icon.color = Globals.theme.foreground;
        }
    }

    Popup {
        id: popup
        ref: bar
        name: "Bluetooth"
        popupHeight: root.popupHeight
        popupWidth: 400
        yPos: popupYpos

        BluetoothPopup {
            id: bluetoothPopup
        }
    }
}
