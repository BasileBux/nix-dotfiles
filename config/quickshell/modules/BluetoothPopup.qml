import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import "../widgets" as Widgets
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

    function connectedDeviceName() {
        var devices = Bluetooth.devices.values;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                return devices[i].name;
        }
        return "";
    }

    function isMacAddress(name) {
        return /^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$/.test(name);
    }

    function clickDevice(device) {
        if (!device.bonded) {
            return device.pair();
        }
        if (device.connected) {
            return device.disconnect();
        }
        device.connect();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Globals.spacing

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Rectangle {
                id: scanButton
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: scanRow.width + Globals.spacing * 1.5 + Globals.spacing * 3
                height: parent.height
                radius: height / 2
                color: root.searching ? Globals.theme.muted : Globals.theme.accent1
                opacity: root.searching ? 0.4 : 1.0

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.searching = !root.searching;
                        Bluetooth.defaultAdapter.pairable = root.searching;
                        Bluetooth.defaultAdapter.discovering = root.searching;
						Globals.playSound(Globals.sounds.click);
                    }
                }

                Row {
                    id: scanRow
                    anchors {
                        left: parent.left
                        leftMargin: Globals.spacing * 1.5
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Globals.spacing * 0.6

                    Widgets.TintIcon {
                        source: "../icons/search.svg"
                        width: Globals.fonts.xlarge
                        height: Globals.fonts.xlarge
                        color: root.searching ? Globals.theme.foreground : Globals.theme.background
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: stopMetrics.width
                        horizontalAlignment: Text.AlignHCenter
                        color: root.searching ? Globals.theme.foreground : Globals.theme.background
                        font.pixelSize: Globals.fonts.small
                        font.family: Globals.theme.fontFamily
                        font.bold: root.searching
                        text: root.searching ? "Stop" : "Scan"
                    }

                    TextMetrics {
                        id: stopMetrics
                        font.pixelSize: Globals.fonts.small
                        font.family: Globals.theme.fontFamily
                        font.bold: true
                        text: "Stop"
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            color: Globals.theme.muted
            font.pixelSize: Globals.fonts.small
            font.family: Globals.theme.fontFamily
            elide: Text.ElideRight
            text: {
                if (root.searching)
                    return "Scanning…";
                var name = root.connectedDeviceName();
                if (name !== "")
                    return "Connected to " + name;
                return "Not connected";
            }
        }

        ListView {
            id: deviceList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            clip: true
            model: Bluetooth.devices

            displayMarginBeginning: -(2 * Globals.spacing)
            displayMarginEnd: -(2 * Globals.spacing)

            delegate: Item {
                id: delegateItem
                width: ListView.view.width
                height: visible ? (device.batteryAvailable ? 38 : 26) + Globals.padding : 0
                visible: !root.isMacAddress(modelData.name)

                property var device: modelData
                readonly property bool isConnecting: device.state === BluetoothDeviceState.Connecting
                readonly property bool isConnected: device.state === BluetoothDeviceState.Connected

                // Play sounds on connection state transitions
                property int _state: device.state ?? BluetoothDeviceState.Disconnected
                property int _prevState: -1
                property bool _init: false
                Component.onCompleted: _init = true
                on_StateChanged: {
                    if (!_init) {
                        _prevState = _state;
                        return;
                    }
                    if (_state === BluetoothDeviceState.Connected) {
                        Globals.playSound(Globals.sounds.toggleOn);
                    } else if (_prevState === BluetoothDeviceState.Connecting
                               && _state === BluetoothDeviceState.Disconnected) {
                        Globals.playSound(Globals.sounds.toggleOff);
                    }
                    _prevState = _state;
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Globals.playSound(Globals.sounds.click);
                        root.clickDevice(device);
                    }
                }

                // Device name
                Text {
                    id: nameText
                    anchors {
                        left: parent.left
                        leftMargin: Globals.spacing
                        right: forgetIcon.left
                        rightMargin: Globals.spacing
                        top: parent.top
                        topMargin: Globals.padding
                    }
                    color: delegateItem.isConnected || delegateItem.isConnecting
                           ? Globals.theme.accent1 : Globals.theme.foreground
                    font.pixelSize: Globals.fonts.medium
                    font.family: Globals.theme.fontFamily
                    font.bold: delegateItem.isConnected
                    elide: Text.ElideRight
                    text: device.name || "(unnamed)"
                }

                // Battery info
                Text {
                    id: batteryText
                    anchors {
                        left: parent.left
                        leftMargin: Globals.spacing
                        top: nameText.bottom
                    }
                    color: Globals.theme.muted
                    font.pixelSize: Globals.fonts.xsmall
                    font.family: Globals.theme.fontFamily
                    visible: device.batteryAvailable
                    text: "Battery: " + (device.battery * 100).toFixed(0) + "%"
                }

                // Forget button
                Widgets.TintIcon {
                    id: forgetIcon
                    anchors {
                        right: parent.right
                        rightMargin: Globals.spacing
                        verticalCenter: nameText.verticalCenter
                    }
                    source: "../icons/cross.svg"
                    width: Globals.fonts.xlarge
                    height: Globals.fonts.xlarge
                    color: Globals.theme.muted
                    visible: device.bonded

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -Globals.spacing
                        onClicked: device.forget()
                    }
                }
            }
        }
    }
}
