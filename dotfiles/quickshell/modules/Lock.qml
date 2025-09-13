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
        // anchors.fill: parent
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        background: Rectangle {
            color: "transparent"
        }
        icon.source: "../icons/shutdown.svg"
        icon.color: Globals.theme.foreground
        icon.width: parent.height * 0.9
        icon.height: parent.height * 0.9
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
        }
        onEntered: {
            lockIcon.icon.color = Globals.theme.accent2;
        }
        onExited: {
            lockIcon.icon.color = Globals.theme.foreground;
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
