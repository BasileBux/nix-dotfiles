import Quickshell
import QtQuick
import QtQuick.Controls
import "../services" as Services
import ".."

Item {
    id: root
    anchors.fill: parent

    required property int popupYpos
    required property int popupHeight
    readonly property alias popup: popupLoader.popup

    Button {
        id: networkIcon
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        background: Rectangle {
            color: "transparent"
        }
        icon.width: parent.width * 0.5
        icon.height: parent.width * 0.5
        icon.color: Globals.theme.foreground
        icon.source: {
            if (Services.Network.scanning || !Services.Network.startupFinished)
                return "../icons/search.svg";
            if (Services.Network.ethernetConnected)
                return "../icons/ethernet.svg";
            if (!Services.Network.wifiEnabled)
                return "../icons/wifi-off.svg";
            if (Services.Network.active)
                return "../icons/wifi-on.svg";
            return "../icons/wifi-problem.svg";
        }
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
                name: "Network"
                popupHeight: 360
                popupWidth: 400
                yPos: popupYpos
                NetworkPopup {}
            }
        }

        Component {
            id: floatPopupComponent
            FloatPopup {
                id: popup
                ref: bar
                name: "Network"
                popupHeight: 360
                popupWidth: 400
                yPos: popupYpos
                NetworkPopup {}
            }
        }
    }
}
