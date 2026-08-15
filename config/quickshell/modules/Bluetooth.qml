import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Controls
import "../widgets" as Widgets
import ".."

Item {
    id: root
    anchors.fill: parent

    required property var moduleRef
    required property int popupHeight
    required property int popupWidth
    readonly property alias popup: popup

    Widgets.TintIcon {
        id: bluetoothIcon
        anchors {
            fill: parent
            // rightMargin: 2 // Slightest adjustment
        }
        source: "../icons/bluetooth.svg"
        width: parent.width * 0.8
        height: parent.width * 0.8
        color: Globals.theme.foreground
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
        }
    }

    Popup {
        id: popup
        ref: bar
        name: "Bluetooth"
        popupHeight: root.popupHeight
        popupWidth: root.popupWidth
        moduleRef: root.moduleRef

        BluetoothPopup {
            id: bluetoothPopup
        }
    }
}
