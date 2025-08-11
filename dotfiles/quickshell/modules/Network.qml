import Quickshell
import QtQuick
import "../services" as Services
import ".."

Item {
    id: root
    anchors.fill: parent

    required property int popupYpos
    required property int popupHeight
    readonly property alias popup: popup

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
        }
        onEntered: {
            networkText.color = Globals.theme.accent2;
        }
        onExited: {
            networkText.color = Globals.theme.foreground;
        }
    }

    Text {
        id: networkText
        horizontalAlignment: Text.AlignHCenter
        anchors.fill: parent
        color: Globals.theme.foreground
        font.pixelSize: Globals.fonts.huge
        text: {
            if (Services.Network.scanning || !Services.Network.startupFinished)
                return " ";
            if (Services.Network.ethernetConnected)
                return " ";
            if (!Services.Network.wifiEnabled)
                return "󰤮 ";
            if (Services.Network.active)
                return "󰖩 ";
            return "󱚼 ";
        }
    }

    Popup {
        id: popup
        ref: bar
        name: "Network"
        popupHeight: 360
        popupWidth: 400
        yPos: popupYpos
        NetworkPopup {}
    }
}
