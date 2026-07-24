import Quickshell
import QtQuick
import QtQuick.Layouts
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

    ColumnLayout {
        anchors.fill: parent
        spacing: -5
        Widgets.TintIcon {
            id: audioIcon
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width * 0.65
            Layout.preferredHeight: parent.width * 0.65
            source: Services.Audio.muted ? "../icons/muted.svg" : "../icons/speaker.svg"
            color: Globals.theme.foreground
        }

        Text {
            id: volumeText
            Layout.alignment: Qt.AlignHCenter
            color: Globals.theme.foreground
            font.pixelSize: Globals.fonts.xsmall + 1 // Weird as fuck but font rendering seems to be fucked
            font.family: Globals.theme.fontFamily
            text: isNaN(Services.Audio.volume) ? "0%" : (Services.Audio.volume * 100).toFixed(0) + "%"
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
        name: "Audio"
        popupHeight: root.popupHeight
        popupWidth: root.popupWidth
        moduleRef: root.moduleRef
        AudioPopup {
            popupShown: popup.shown
        }
    }
}
