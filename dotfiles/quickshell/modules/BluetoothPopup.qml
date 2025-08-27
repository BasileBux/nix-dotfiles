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
            implicitHeight: 36
            Rectangle {
                id: searchButton
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                implicitWidth: 86
                radius: width / 2
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
                    hoverEnabled: true
                    onClicked: {
                        if (!searching) {
                            searching = true;
                            searchButton.color = Globals.theme.accent1;
                            Bluetooth.defaultAdapter.pairable = true;
                            Bluetooth.defaultAdapter.discovering = true;
                            return;
                        }
                        searching = false;
                        searchButton.color = Globals.theme.accent3;
                        Bluetooth.defaultAdapter.pairable = false;
                        Bluetooth.defaultAdapter.discovering = false;
                    }
                    onEntered: {
                        searchButton.color = Globals.theme.accent2;
                    }
                    onExited: {
                        searchButton.color = !searching ? Globals.theme.accent1 : Globals.theme.accent3;
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
            implicitHeight: 45
            implicitWidth: parent.width

            Text {
                id: nameText
                color: device.connected ? Globals.theme.accent1 : Globals.theme.foreground
                font.pixelSize: Globals.fonts.medium
                font.family: Globals.theme.fontFamily
                anchors {
                    top: parent.top
                    topMargin: Globals.padding * 3
                    left: parent.left
                    leftMargin: Globals.spacing
                }
                text: device.name

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: clickDevice(device, nameText)
                    onEntered: {
                        nameText.color = Globals.theme.accent2;
                    }
                    onExited: {
                        nameText.color = device.connected ? Globals.theme.accent1 : Globals.theme.foreground;
                    }
                }
            }
            Text {
                id: batteryText
                color: Globals.theme.foreground
                font.pixelSize: Globals.fonts.small
                font.family: Globals.theme.fontFamily
                anchors {
                    left: parent.left
                    leftMargin: Globals.spacing
                    bottom: parent.bottom
                }
                text: device.batteryAvailable ? "Battery: " + (device.battery * 100).toFixed(0) + "%" : ""
            }
            Text {
                id: forgetText
                anchors {
                    right: parent.right
                    rightMargin: Globals.spacing
                    verticalCenter: parent.verticalCenter
                    topMargin: Globals.padding * 3
                }
                visible: device.bonded
                color: Globals.theme.foreground
                font.pointSize: Globals.fonts.xlarge
                font.family: Globals.theme.fontFamily
                font.bold: true
                text: ""

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: device.forget()
                    onEntered: {
                        forgetText.color = Globals.theme.accent2;
                    }
                    onExited: {
                        forgetText.color = Globals.theme.foreground;
                    }
                }
            }
        }
    }
}
