import Quickshell
import Quickshell.Io
import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent
    readonly property alias popup: popup

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
        }
        onEntered: {
            lockText.color = Globals.theme.accent2;
        }
        onExited: {
            lockText.color = Globals.theme.foreground;
        }
    }

    Text {
        id: lockText
        horizontalAlignment: Text.AlignHCenter
        anchors.fill: parent
        color: Globals.theme.foreground
        font.pixelSize: Globals.fonts.xlarge
        text: " "
    }

    Popup {
        id: popup
        ref: bar
        name: "Lock"
        popupHeight: bar.height * 0.4
        popupWidth: popupHeight * 0.2 + 2 * Globals.padding
        yPos: ref.height / 2 - popupHeight / 2
        LockPopup {}
    }
}
