import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import ".."

Item {
    id: root
    anchors.fill: parent
    readonly property alias popup: popupLoader.popup

    Button {
        id: lockIcon
        anchors.fill: parent

        background: Rectangle {
            color: "transparent"
        }
        icon.source: "../icons/power.svg"
        icon.color: Globals.theme.foreground
        icon.width: parent.height
        icon.height: parent.height
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            popup.toggle();
            lockFocusGrab.active = popup.shown;
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
                name: "Lock"
                popupHeight: bar.height * 0.4
                popupWidth: popupHeight * 0.2 + 2 * Globals.padding
                yPos: ref.height / 2 - popupHeight / 2
                LockPopup {
                    lock: bar.lock
                }
            }
        }

        Component {
            id: floatPopupComponent
            FloatPopup {
                id: popup
                ref: bar
                name: "Lock"
                popupHeight: bar.height * 0.4
                popupWidth: popupHeight * 0.2 + 2 * Globals.padding
                yPos: ref.height / 2 - popupHeight / 2
                LockPopup {
                    lock: bar.lock
                }
            }
        }
    }
}
