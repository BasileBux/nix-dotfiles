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
    readonly property alias popup: popupLoader.popup

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
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
        }
    }

    Loader {
        id: popupLoader
        sourceComponent: Globals.popup === "FloatPopup" ? floatPopupComponent : regularPopupComponent

        property var popup: popupLoader.item

        Component {
            id: regularPopupComponent
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

        Component {
            id: floatPopupComponent
            FloatPopup {
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
    }
}
