import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ".."

Item {
    id: root
    anchors.fill: parent
    property int popupYpos
    required property int popupWidth
    required property int popupHeight
    readonly property alias popup: popupLoader.popup

    readonly property var chargeState: UPower.displayDevice.state
    readonly property bool isCharging: chargeState == UPowerDeviceState.Charging
    readonly property bool isDocked: chargeState != UPowerDeviceState.Charging && UPower.displayDevice.changeRate <= 0.01
    readonly property real percentage: UPower.displayDevice.percentage
    readonly property bool isLow: percentage <= 0.30

    MouseArea {
        anchors.fill: parent
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
        }
        z: 1000
    }

    ColumnLayout {
        id: layout
        spacing: -5
        anchors.fill: parent

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: chargeOverlay
                width: batteryIcon.width * 0.34
                height: batteryIcon.height * (root.percentage) * 0.64
                color: root.isCharging ? "#20FF4F" : root.isLow ? "#FD788B" : "green"
                x: batteryIcon.width / 2 - width / 2
                y: batteryIcon.height - height - batteryIcon.height * 0.2
                radius: 2
            }

            Button {
                id: batteryIcon
                anchors.fill: parent
                background: Rectangle {
                    color: "transparent"
                }
                icon.source: "../icons/battery-vertical.svg"
                icon.width: parent.width
                icon.height: parent.width
                icon.color: Globals.theme.foreground
            }
        }

        Text {
            id: percentageText
            Layout.alignment: Qt.AlignHCenter
            color: root.isCharging ? "#20FF4F" : root.isLow ? "#FD788B" : Globals.theme.foreground
            font.pointSize: Globals.fonts.tiny
            font.family: Globals.theme.fontFamily
            text: (root.percentage * 100).toFixed(0) + "%"
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
                yPos: root.popupYpos
                name: "Battery"

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    BatteryPopup {
                        popupWidth: root.popupWidth
                        moduleRef: batteryContent
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
                yPos: root.popupYpos
                name: "Battery"

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    BatteryPopup {
                        popupWidth: root.popupWidth
                        moduleRef: batteryContent
                    }
                }
            }
        }
    }
}
