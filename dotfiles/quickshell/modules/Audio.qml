import Quickshell
import QtQuick
import QtQuick.Layouts
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

    ColumnLayout {
        anchors.fill: parent
        spacing: -5
        Button {
            id: audioIcon
            Layout.alignment: Qt.AlignHCenter
            background: Rectangle {
                color: "transparent"
            }
            icon.source: Services.Audio.muted ? "../icons/muted.svg" : "../icons/audio.svg"
            icon.width: parent.width * 0.5
            icon.height: parent.width * 0.5
            icon.color: Globals.theme.foreground
        }

        Text {
            id: volumeText
            Layout.alignment: Qt.AlignHCenter
            color: Globals.theme.foreground
            font.pixelSize: Globals.fonts.xsmall + 1 // Weird as fuck but font rendering seems to be fucked
            font.family: Globals.theme.fontFamily
            text: Services.Audio.volume === (0 / 0) ? "0%" : (Services.Audio.volume * 100).toFixed(0) + "%"
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
                name: "Audio"
                popupHeight: root.popupHeight
                popupWidth: root.popupWidth
                yPos: root.popupYpos
                AudioPopup {}
            }
        }

        Component {
            id: floatPopupComponent
            FloatPopup {
                id: popup
                ref: bar
                name: "Audio"
                popupHeight: root.popupHeight
                popupWidth: root.popupWidth
                yPos: root.popupYpos
                AudioPopup {}
            }
        }
    }
}
