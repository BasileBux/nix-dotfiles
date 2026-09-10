import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Networking as Net
import "../../services" as Services
import "../widgets" as PWidgets
import "../../widgets" as Widgets
import "../.."

Item {
    id: root

    readonly property bool hasProblem: !Services.Network.wifiDevice || !Services.Network.wifiHardwareEnabled
    readonly property bool popupShown: PaletteState.viewId === "network"
    readonly property bool online: Services.Network.wifiConnected || Services.Network.ethernetConnected
    readonly property string stateText: {
        if (Services.Network.ethernetConnected)
            return "Connected via Ethernet";
        if (!Services.Network.wifiEnabled)
            return "Wi-Fi is disabled";
        if (Services.Network.wifiConnected)
            return "Connected to " + Services.Network.activeSsid;
        if (Services.Network.scanning)
            return "Scanning…";
        if (root.hasProblem)
            return "No Wi-Fi device";
        return "Not connected";
    }

    // The view stays instantiated while the palette is hidden; reset the
    // scroll so it doesn't reopen at the old position.
    onVisibleChanged: if (!visible)
        networkListView.contentY = 0

    // Scan runs only while the view is open
    onPopupShownChanged: {
        if (popupShown) {
            Services.Network.startScan();
        } else {
            Services.Network.stopScan();
        }
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

                // BUG: When toggling on, the audio plays twice
                Widgets.Switch {
                    id: wifiToggle

                    toggleFunction: Services.Network.toggleWifi
                    toggleState: Services.Network.wifiEnabled
                }
                Text {
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.body
                    text: "Wi-Fi"
                }
                Rectangle {
                    color: root.online ? Globals.colors.success : Globals.colors.warning
                    height: 7
                    radius: 3.5
                    visible: root.online || root.hasProblem
                    width: 7
                }
                Text {
                    Layout.fillWidth: true
                    color: root.hasProblem && !root.online ? Globals.colors.warning : Globals.theme.foreground
                    elide: Text.ElideRight
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    text: root.stateText
                }
                Text {
                    visible: Services.Network.scanning && root.online
                    text: "Scanning Wi-Fi…"
                    color: Globals.theme.muted
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                }
                PWidgets.IconButton {
                    danger: true
                    icon: "warning"
                    visible: root.hasProblem && !root.online
                }
            }

            // Ethernet is a row of its own: the header sentence used to swallow
            // it, which is why the Home tile had to lie about the connection.
            PWidgets.Row {
                Layout.fillWidth: true
                caption: "Connected"
                height: 44
                icon: "globe"
                iconSize: 24
                iconWell: false
                selected: Services.Network.ethernetConnected
                title: "Ethernet"
                visible: Services.Network.ethernetConnected

                Rectangle {
                    color: Globals.colors.success
                    height: 7
                    radius: 3.5
                    width: 7
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
                visible: Services.Network.ethernetConnected
            }

            ListView {
                id: networkListView

                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                model: Services.Network.wifiDevice?.networks ?? null
                spacing: Globals.space1
                visible: count > 0

                delegate: Item {
                    id: networkDelegateItem

                    required property int index
                    required property var modelData
                    readonly property bool connectingNetwork: (modelData.state ?? 0) === Net.ConnectionState.Connecting
                    readonly property bool connectedNetwork: modelData.connected === true
                    readonly property bool knownNetwork: modelData.known === true
                    readonly property real signalStrength: modelData.signalStrength ?? 0

                    height: 44
                    width: ListView.view.width

                    Widgets.ConnectionSounds {
                        connectedState: Net.ConnectionState.Connected
                        connectingState: Net.ConnectionState.Connecting
                        disconnectedState: Net.ConnectionState.Disconnected
                        state: modelData.state ?? Net.ConnectionState.Unknown
                    }
                    PWidgets.Row {
                        anchors.fill: parent
                        caption: {
                            if (networkDelegateItem.connectingNetwork)
                                return "Connecting…";
                            var sec = modelData.security;
                            if (sec === undefined || sec === null || sec === Net.WifiSecurityType.Open)
                                return "";
                            return Net.WifiSecurityType.toString(sec);
                        }
                        selected: networkDelegateItem.connectedNetwork
                        title: modelData.name || "(unnamed)"

                        leading: Row {
                            spacing: Globals.space1

                            Repeater {
                                model: 4

                                Item {
                                    implicitHeight: 14
                                    implicitWidth: 3

                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        color: {
                                            if (networkDelegateItem.signalStrength < index * 0.22)
                                                return Qt.rgba(1, 1, 1, 0.14);
                                            return networkDelegateItem.connectedNetwork ? Globals.accent : Globals.theme.foreground;
                                        }
                                        height: 4 + index * 3
                                        radius: 1.5
                                        width: 3
                                    }
                                }
                            }
                        }

                        onClicked: {
                            Globals.playSound(Globals.sounds.click);
                            if (modelData.connected) {
                                modelData.disconnect();
                            } else {
                                modelData.connect();
                            }
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: networkListView.count === 0

                PWidgets.EmptyState {
                    anchors.centerIn: parent
                    caption: Services.Network.scanning ? "Scanning…" : "Move closer to the router"
                    icon: "wifi-problem"
                    title: "No networks"
                }
            }
        }
    }
}
