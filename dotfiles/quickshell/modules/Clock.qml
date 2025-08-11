import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    anchors.fill: parent
    property int popupYpos
    required property int popupHeight
    readonly property alias popup: popup

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            popup.toggle();
        }
        onEntered: {
            hourText.color = Globals.theme.accent2;
            minuteText.color = Globals.theme.accent2;
        }
        onExited: {
            hourText.color = Globals.theme.foreground;
            minuteText.color = Globals.theme.foreground;
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    ColumnLayout {
        id: layout
        spacing: -10

        anchors {
            fill: parent
        }

        Text {
            id: hourText
            Layout.alignment: Qt.AlignHCenter
            color: Globals.theme.foreground
            font.pointSize: Globals.fonts.large
            text: Qt.formatDateTime(clock.date, "hh")
        }

        Text {
            id: minuteText
            Layout.alignment: Qt.AlignHCenter
            color: Globals.theme.foreground
            font.pointSize: Globals.fonts.large
            text: Qt.formatDateTime(clock.date, "mm")
        }
    }

    Popup {
        id: popup
        ref: bar
        popupWidth: 120
        popupHeight: root.popupHeight
        yPos: popupYpos
        name: "Clock"

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            Text {
                anchors.centerIn: parent
                color: Globals.theme.foreground
                font.pixelSize: Globals.fonts.medium
                text: Qt.formatDateTime(clock.date, "dd-MM-yyyy")
            }
        }
    }
}
