import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "../widgets" as Widgets
import ".."

Item {
    id: root
    anchors.fill: parent
    readonly property alias popup: popup

    Widgets.TintIcon {
        id: lockIcon
        anchors.fill: parent

        source: "../icons/power.svg"
        color: Globals.theme.foreground
        width: parent.height
        height: parent.height
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            popup.toggle();
            lockFocusGrab.active = popup.shown;
        }
    }

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
