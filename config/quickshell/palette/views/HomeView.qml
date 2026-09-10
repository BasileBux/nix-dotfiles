import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "../widgets" as PWidgets
import "../../widgets" as Widgets
import "../../services" as Services
import "../.."

Item {
    id: root

    readonly property string btDeviceName: {
        const devices = Bluetooth.devices.values;
        for (let i = 0; i < devices.length; i++)
            if (devices[i].connected)
                return devices[i].name;
        return "";
    }
    readonly property bool isCharging: UPower.displayDevice.state == UPowerDeviceState.Charging
    readonly property bool isDocked: !isCharging && UPower.displayDevice.changeRate <= 0.01
    readonly property real percentage: UPower.displayDevice.percentage
    readonly property string batteryState: isCharging ? "Charging" : isDocked ? "Docked" : "Discharging"
    readonly property string networkCaption: Services.Network.ethernetConnected ? "Connected" : !Services.Network.wifiEnabled ? "Disabled" : Services.Network.wifiConnected ? "Connected" : "Not connected"
    readonly property string networkIcon: Services.Network.ethernetConnected ? "globe" : !Services.Network.wifiEnabled ? "wifi-off" : Services.Network.wifiConnected ? "wifi-on" : "wifi-problem"
    readonly property string networkValue: Services.Network.ethernetConnected ? "Ethernet" : Services.Network.wifiConnected && Services.Network.activeSsid !== "" ? Services.Network.activeSsid : "Wi-Fi"

    function handleKey(event) {
        if (event.key === Qt.Key_Left) {
            Services.Mpris.previous();
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Right) {
            Services.Mpris.next();
            event.accepted = true;
            return;
        }
        if (!(event.modifiers & Qt.ControlModifier))
            return;
        const map = {};
        map[Qt.Key_A] = "mixer";
        map[Qt.Key_B] = "bluetooth";
        map[Qt.Key_C] = "clock";
        map[Qt.Key_N] = "notifications";
        map[Qt.Key_O] = "apps";
        map[Qt.Key_P] = "power";
        map[Qt.Key_R] = "remote";
        map[Qt.Key_T] = "tailscale";
        map[Qt.Key_U] = "battery";
        map[Qt.Key_W] = "network";
        if (map[event.key]) {
            PaletteState.navigate(map[event.key]);
            event.accepted = true;
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Globals.margin

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 176
            spacing: Globals.margin

            PWidgets.Surface {
                Layout.preferredHeight: 176
                Layout.preferredWidth: 424
                interactive: true
                onClicked: PaletteState.navigate("clock")

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Globals.space1
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: Globals.theme.foreground
                        font.family: Globals.theme.fontFamily
                        font.features: {
                            "tnum": 1
                        }
                        font.letterSpacing: -1
                        font.pixelSize: Globals.fonts.display
                        font.weight: Font.DemiBold
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        color: Globals.theme.muted
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.body
                        text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
                    }
                }
            }
            PWidgets.Tile {
                Layout.preferredHeight: 176
                Layout.preferredWidth: 248
                caption: root.batteryState
                value: Globals.percent(root.percentage)
                valueColor: root.percentage <= 0.15 ? Globals.colors.danger : Globals.theme.foreground
                valueSize: Globals.fonts.metric
                wellSize: 64
                iconComponent: Component {
                    PWidgets.BatteryRing {
                        charging: root.isCharging
                        level: root.percentage
                        thickness: 5
                    }
                }
                onClicked: PaletteState.navigate("battery")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 88
            spacing: Globals.margin
            PWidgets.MediaCard {
                Layout.preferredHeight: 88
                Layout.preferredWidth: 512
            }
            PWidgets.Surface {
                Layout.preferredHeight: 88
                Layout.preferredWidth: 160
                interactive: true
                onClicked: PaletteState.navigate("mixer")
                Row {
                    anchors.centerIn: parent
                    spacing: Globals.space2
                    Widgets.TintIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Services.Audio.muted ? Globals.theme.muted : Globals.theme.foreground
                        height: 24
                        width: 24
                        name: Services.Audio.muted ? "muted" : "speaker"
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Globals.theme.foreground
                        font.family: Globals.theme.fontFamily
                        font.features: {
                            "tnum": 1
                        }
                        font.pixelSize: Globals.fonts.title + 2 // Slight adjustment else it looks bad idk why
                        font.weight: Font.DemiBold
                        text: Globals.percent(isNaN(Services.Audio.volume) ? 0 : Services.Audio.volume)
                    }
                }
                WheelHandler {
                    onWheel: event => Services.Audio.adjustVolume(event.angleDelta.y > 0)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 84
            spacing: Globals.margin
            PWidgets.Tile {
                Layout.preferredHeight: 84
                Layout.preferredWidth: 160
                caption: Services.Notifications.doNotDisturb ? "Do not disturb" : Services.Notifications.count > 0 ? "Pending" : "Notifications"
                icon: "bell"
                valueSize: Globals.fonts.body
                value: Services.Notifications.count > 0 ? Services.Notifications.count.toString() : "All clear"
                onClicked: PaletteState.navigate("notifications")
            }
            PWidgets.Tile {
                Layout.preferredHeight: 84
                Layout.preferredWidth: 248
                caption: root.btDeviceName !== "" ? "Connected" : "Not connected"
                icon: "bluetooth"
                value: root.btDeviceName !== "" ? root.btDeviceName : "Bluetooth"
                onClicked: PaletteState.navigate("bluetooth")
            }
            PWidgets.Tile {
                Layout.preferredHeight: 84
                Layout.preferredWidth: 248
                caption: root.networkCaption
                icon: root.networkIcon
                value: root.networkValue
                onClicked: PaletteState.navigate("network")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            spacing: Globals.space2

            RowLayout {
                spacing: Globals.space2
                Repeater {
                    model: 6
                    delegate: Rectangle {
                        id: workspaceButton
                        required property int index
                        readonly property int workspaceIndex: index + 1
                        readonly property var workspace: Hyprland.workspaces.values.find(w => w.id === workspaceIndex) ?? null
                        readonly property bool active: Hyprland.focusedWorkspace?.id === workspaceIndex
                        readonly property bool urgent: workspace?.urgent ?? false
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: 44
                        radius: height / 2
                        color: active ? Globals.accentFill : wsMouse.containsMouse ? Globals.surfaceHover : Globals.surface
                        border.width: 1
                        border.color: urgent ? Globals.colors.warning : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: workspaceButton.workspaceIndex
                            color: workspaceButton.active ? Globals.accent : Globals.theme.muted
                            font.family: Globals.theme.fontFamily
                            font.pixelSize: Globals.fonts.caption
                            font.weight: Font.DemiBold
                        }
                        MouseArea {
                            id: wsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = ${workspaceButton.workspaceIndex}})`)
                        }
                    }
                }
            }
            Item {
                Layout.fillWidth: true
            }
            RowLayout {
                spacing: Globals.space1
                Repeater {
                    model: [
                        {
                            icon: "lock",
                            label: "Lock",
                            exec: PaletteState.lockScreen,
                            danger: false
                        },
                        {
                            icon: "logout",
                            label: "Log out",
                            exec: PaletteState.logout,
                            danger: true
                        },
                        {
                            icon: "reboot",
                            label: "Reboot",
                            exec: PaletteState.reboot,
                            danger: true
                        },
                        {
                            icon: "shutdown",
                            label: "Shut down",
                            exec: PaletteState.shutdown,
                            danger: true
                        }
                    ]
                    delegate: PWidgets.IconButton {
                        required property var modelData
                        icon: modelData.icon
                        tooltip: modelData.label
                        danger: modelData.danger
                        size: 36
                        iconSize: 22
                        onClicked: modelData.exec()
                    }
                }
            }
        }
    }
}
