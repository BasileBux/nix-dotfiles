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
    required property int popupWidth
    readonly property alias popup: popupLoader.popup

    Button {
        id: networkIcon
        anchors {
            fill: parent
            // rightMargin: 1 // Slightest adjustment
        }
        background: Rectangle {
            color: "transparent"
        }
        icon.width: parent.width * 0.6
        icon.height: parent.width * 0.6
        icon.color: Globals.theme.foreground
        icon.source: {
            if (Services.Network.scanning || !Services.Network.startupFinished)
                return "../icons/search.svg";
            if (Services.Network.ethernetConnected)
                return "../icons/globe.svg";
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
                popupHeight: root.popupHeight
                popupWidth: root.popupWidth
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
                popupHeight: root.popupHeight
                popupWidth: root.popupWidth
                yPos: popupYpos
                NetworkPopup {}
            }
        }
    }
}
