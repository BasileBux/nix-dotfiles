import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    anchors {
        fill: parent
        topMargin: Globals.spacing
        leftMargin: Globals.spacing
        rightMargin: Globals.spacing
    }

    property bool searching: false

    ColumnLayout {
        anchors.fill: parent
        spacing: Globals.spacing * 2

        Item {
            Layout.fillWidth: true
            implicitHeight: 32
            Rectangle {
                id: searchButton
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                implicitWidth: 76
                radius: Globals.radius
                color: Globals.theme.accent1
                Text {
                    id: searchText
                    anchors.centerIn: parent
                    color: Globals.theme.background
                    font.pointSize: Globals.fonts.xsmall
                    font.family: Globals.theme.fontFamily
                    text: "Search"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!searching) {
                            searching = true;
                            searchButton.color = Globals.theme.accent3;
                            Bluetooth.defaultAdapter.pairable = true;
                            Bluetooth.defaultAdapter.discovering = true;
                            return;
                        }
                        searching = false;
                        searchButton.color = Globals.theme.accent1;
                        Bluetooth.defaultAdapter.pairable = false;
                        Bluetooth.defaultAdapter.discovering = false;
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView {
                id: deviceList
                anchors.fill: parent
                spacing: Globals.spacing

                model: Bluetooth.devices
                delegate: bluetoothDelegate

                displayMarginBeginning: -(2 * Globals.spacing)
                displayMarginEnd: -(2 * Globals.spacing)
            }
        }
    }

    function clickDevice(device, nameText) {
        if (!device.bonded) {
            nameText.color = Globals.theme.accent1;
            return device.pair();
        }
        if (device.connected) {
            nameText.color = Globals.theme.foreground;
            return device.disconnect();
        }
        nameText.color = Globals.theme.accent1;
        device.connect();
    }

    Component {
        id: bluetoothDelegate
        Item {
            id: item
            property var device: modelData
            implicitHeight: device.batteryAvailable ? 38 : 20
            implicitWidth: parent.width

            Text {
                id: nameText
                color: device.state == BluetoothDeviceState.Connecting || device.state == BluetoothDeviceState.Connected ? Globals.theme.accent1 : Globals.theme.foreground
                font.pixelSize: Globals.fonts.medium
                font.family: Globals.theme.fontFamily
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: Globals.spacing
                }
                text: device.name

                MouseArea {
                    anchors.fill: parent
                    onClicked: clickDevice(device, nameText)
                }
            }
            Text {
                id: batteryText
                color: Globals.theme.muted
                font.pixelSize: Globals.fonts.small
                font.family: Globals.theme.fontFamily
                anchors {
                    left: parent.left
                    leftMargin: Globals.spacing
                    top: nameText.bottom
                }
                text: device.batteryAvailable ? "Battery: " + (device.battery * 100).toFixed(0) + "%" : ""
            }
            Text {
                id: forgetText
                anchors {
                    right: parent.right
                    rightMargin: Globals.spacing
                    top: parent.top
                    topMargin: -3
                }
                visible: device.bonded
                color: Globals.theme.foreground
                font.pointSize: Globals.fonts.medium
                font.family: Globals.theme.fontFamily
                font.bold: true
                text: ""

                MouseArea {
                    anchors.fill: parent
                    onClicked: device.forget()
                }
            }
        }
    }
}
