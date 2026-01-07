import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    anchors.fill: parent
    property int popupYpos
    required property int popupHeight
    required property int popupWidth
    readonly property alias popup: popupLoader.popup
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

    Loader {
        id: popupLoader
        sourceComponent: Globals.popup === "FloatPopup" ? floatPopupComponent : regularPopupComponent

        property var popup: popupLoader.item

        Component {
            id: regularPopupComponent
            Popup {
                id: popup
                ref: bar
                popupWidth: root.popupWidth
                popupHeight: root.popupHeight
                yPos: popupYpos
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

        Component {
            id: floatPopupComponent
            FloatPopup {
                id: popup
                ref: bar
                popupWidth: root.popupWidth
                popupHeight: root.popupHeight
                yPos: popupYpos
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
    }
}
