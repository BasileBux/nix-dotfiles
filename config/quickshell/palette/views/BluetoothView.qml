import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import "../widgets" as PWidgets
import "../../widgets" as Widgets
import "../.."

Item {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool scanning: adapter?.discovering ?? false

    // The view stays instantiated while the palette is hidden; reset the
    // scroll so it doesn't reopen at the old position.
    onVisibleChanged: if (!visible)
        deviceList.contentY = 0

    function clickDevice(device) {
        if (!device.bonded) {
            return device.pair();
        }
        if (device.connected) {
            return device.disconnect();
        }
        device.connect();
    }
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
    function setEnabled(on) {
        if (!root.adapter)
            return;
        root.adapter.enabled = on;
        root.adapter.pairable = on;
        root.adapter.discovering = on;
        Globals.playSound(Globals.sounds.click);
    }
    function stateText() {
        if (!root.adapter || !root.adapter.enabled)
            return "Off";
        if (root.scanning)
            return "Scanning…";
        return root.connectedDeviceName() !== "" ? "Connected" : "Not connected";
    }

    Item {
        anchors.fill: parent
        anchors.margins: Globals.space2

        ColumnLayout {
            anchors.fill: parent
            spacing: Globals.space2

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                spacing: Globals.space2

                Widgets.Switch {
                    toggleFunction: () => root.setEnabled(!(root.adapter?.enabled ?? false))
                    toggleState: root.adapter?.enabled ?? false
                }
                Text {
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.body
                    text: "Bluetooth"
                }
                Rectangle {
                    color: Globals.colors.success
                    height: 7
                    radius: 3.5
                    visible: root.connectedDeviceName() !== "" && !root.scanning
                    width: 7
                }
                Text {
                    Layout.fillWidth: true
                    color: Globals.theme.foreground
                    elide: Text.ElideRight
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    text: root.stateText()
                }
                PWidgets.IconButton {
                    icon: "refresh"
                    tooltip: "Scan for devices"
                    visible: root.adapter?.enabled ?? false

                    onClicked: {
                        if (root.adapter)
                            root.adapter.discovering = true;
                    }
                }
            }
            ListView {
                id: deviceList

                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                model: Bluetooth.devices
                // A forgotten/MAC-named device keeps its slot at zero height.
                spacing: Globals.space1
                visible: count > 0

                delegate: Item {
                    id: delegateItem

                    required property int index
                    required property var modelData
                    readonly property var device: modelData
                    readonly property bool bondedDevice: device?.bonded ?? false
                    readonly property bool connectingDevice: (device?.state ?? 0) === BluetoothDeviceState.Connecting
                    readonly property bool connectedDevice: (device?.state ?? 0) === BluetoothDeviceState.Connected
                    readonly property bool hiddenDevice: root.isMacAddress(device?.name ?? "")

                    height: hiddenDevice ? 0 : 44
                    width: ListView.view.width

                    Widgets.ConnectionSounds {
                        connectedState: BluetoothDeviceState.Connected
                        connectingState: BluetoothDeviceState.Connecting
                        disconnectedState: BluetoothDeviceState.Disconnected
                        state: delegateItem.device?.state ?? BluetoothDeviceState.Disconnected
                    }
                    PWidgets.Row {
                        anchors.fill: parent
                        caption: delegateItem.device?.batteryAvailable ?? false ? "Battery " + Globals.percent(delegateItem.device.battery) : ""
                        icon: "bluetooth"
                        iconSize: 24
                        iconWell: false
                        selected: delegateItem.connectedDevice
                        title: delegateItem.device?.name || "(unnamed)"
                        visible: !delegateItem.hiddenDevice

                        onClicked: {
                            Globals.playSound(Globals.sounds.click);
                            root.clickDevice(delegateItem.device);
                        }

                        PWidgets.IconButton {
                            danger: true
                            icon: "cross"
                            iconSize: 20
                            size: 36
                            tooltip: "Forget device"
                            visible: delegateItem.bondedDevice

                            onClicked: delegateItem.device.forget()
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: Bluetooth.devices.values.length === 0

                PWidgets.EmptyState {
                    anchors.centerIn: parent
                    caption: "Put the device in pairing mode"
                    icon: "bluetooth"
                    title: "No devices"
                }
            }
        }
    }
}
