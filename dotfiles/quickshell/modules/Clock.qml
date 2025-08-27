import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    anchors.fill: parent
    property int popupYpos
    required property int popupHeight
    readonly property alias popup: popupLoader.popup

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
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
            font.family: Globals.theme.fontFamily
            text: Qt.formatDateTime(clock.date, "hh")
        }

        Text {
            id: minuteText
            Layout.alignment: Qt.AlignHCenter
            color: Globals.theme.foreground
            font.pointSize: Globals.fonts.large
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
                popupWidth: 120
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
                popupWidth: 120
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
