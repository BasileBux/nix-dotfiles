import Quickshell
import QtQuick
import QtQuick.Controls
import "../services" as Services
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
        id: networkIcon
        anchors.fill: parent

        width: parent.width * 0.6
        height: parent.width * 0.6
        color: Globals.theme.foreground
        source: {
            if (Services.Network.ethernetConnected)
                return "../icons/globe.svg";
            if (!Services.Network.wifiEnabled)
                return "../icons/wifi-off.svg";
            if (Services.Network.wifiConnected)
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

    Popup {
        id: popup
        ref: bar
        name: "Network"
        popupHeight: root.popupHeight
        popupWidth: root.popupWidth
        moduleRef: root.moduleRef
        NetworkPopup {
            popupShown: popup.shown
        }
    }
}
