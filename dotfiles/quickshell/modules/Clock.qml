import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    anchors.fill: parent
    required property var moduleRef
    required property int popupHeight
    required property int popupWidth
    readonly property alias popup: popup
    readonly property int fontSize: Globals.fonts.small

    MouseArea {
        anchors.fill: parent
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    ColumnLayout {
        id: layout
        spacing: -6
        anchors {
			topMargin: -(layout.spacing) / 2
            fill: parent
        }
        Text {
            id: hourText
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            color: Globals.theme.foreground
            font.pointSize: root.fontSize
            font.family: Globals.theme.fontFamily
            text: Qt.formatDateTime(clock.date, "hh")
        }

        Text {
            id: minuteText
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            color: Globals.theme.foreground
            font.pointSize: root.fontSize
            font.family: Globals.theme.fontFamily
            text: Qt.formatDateTime(clock.date, "mm")
        }
    }

    Popup {
        id: popup
        ref: bar
        popupWidth: root.popupWidth
        popupHeight: root.popupHeight
        moduleRef: root.moduleRef
        name: "Clock"

        Item {
            anchors.fill: parent

            Text {
                anchors.centerIn: parent
                color: Globals.theme.foreground
                font.pixelSize: Globals.fonts.medium
                font.family: Globals.theme.fontFamily
                text: Qt.formatDateTime(clock.date, "dd-MM-yyyy")
            }
        }
    }
}
