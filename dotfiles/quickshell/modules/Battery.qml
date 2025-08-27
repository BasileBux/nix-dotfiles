import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    anchors.fill: parent
    property int popupYpos
    required property int popupHeight
    readonly property alias popup: popupLoader.popup

    readonly property var chargeState: UPower.displayDevice.state
    readonly property bool isCharging: chargeState == UPowerDeviceState.Charging
    readonly property bool isDocked: chargeState != UPowerDeviceState.Charging && UPower.displayDevice.changeRate <= 0.01
    readonly property real percentage: UPower.displayDevice.percentage
    readonly property bool isLow: percentage <= 0.30

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            popup.toggle();
            bar.focusGrab.active = popup.shown;
        }
        onEntered: {
            var color = root.isCharging ? "#00cc2c" : root.isLow ? "#fc3654" : Globals.theme.accent2;
            iconText.color = color;
            percentageText.color = color;
        }
        onExited: {
            var color = root.isCharging ? "#20FF4F" : isLow ? "#FD788B" : Globals.theme.foreground;
            iconText.color = color;
            percentageText.color = color;
        }
    }

    ColumnLayout {
        id: layout
        spacing: -8
        anchors.fill: parent

        Text {
            id: iconText
            Layout.alignment: Qt.AlignHCenter
            color: isCharging ? "#20FF4F" : root.isLow ? "#FD788B" : Globals.theme.foreground
            font.pointSize: Globals.fonts.xlarge
            font.family: Globals.theme.fontFamily
            text: root.isDocked ? "󰇅" : root.isCharging ? "󰂄" : (root.isLow ? "󰁺" : (root.percentage >= 0.90 ? "󰁹" : (root.percentage >= 0.80 ? "󰂂" : (root.percentage >= 0.70 ? "󰂁" : (root.percentage >= 0.60 ? "󰂀" : (root.percentage >= 0.50 ? "󰁿" : (root.percentage >= 0.40 ? "󰁾" : (root.percentage >= 0.30 ? "󰁽" : (root.percentage >= 0.20 ? "󰁼" : "󰁻")))))))))
        }

        Text {
            id: percentageText
            Layout.alignment: Qt.AlignHCenter
            color: root.isCharging ? "#20FF4F" : root.isLow ? "#FD788B" : Globals.theme.foreground
            font.pointSize: Globals.fonts.small
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
                popupWidth: 360
                popupHeight: root.popupHeight
                yPos: root.popupYpos
                name: "Battery"

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    BatteryPopup {
                        popupWidth: 360
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
                popupWidth: 360
                popupHeight: root.popupHeight
                yPos: root.popupYpos
                name: "Battery"

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    BatteryPopup {
                        popupWidth: 360
                        moduleRef: batteryContent
                    }
                }
            }
        }
    }
}
