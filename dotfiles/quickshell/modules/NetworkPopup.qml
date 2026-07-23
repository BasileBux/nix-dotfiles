import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Networking as Net
import "../services" as Services
import "../widgets" as Widgets
import ".."

Item {
    id: root
    anchors.fill: parent
    anchors.topMargin: Globals.spacing
    anchors.leftMargin: Globals.spacing

    required property bool popupShown

    // Scan runs only while the popup is open
    onPopupShownChanged: {
        if (popupShown) {
            Services.Network.startScan();
        } else {
            Services.Network.stopScan();
        }
    }

    readonly property bool hasProblem: !Services.Network.wifiDevice || !Services.Network.wifiHardwareEnabled

    readonly property color indicatorColor: {
        if (hasProblem || (popupShown && !Services.Network.scanning))
            return Globals.theme.accent1;	// highlighted — problem, or scan settled
        if (Services.Network.scanning)
            return Globals.theme.muted;		// grey — scan in progress
        return Globals.theme.foreground;	// white — idle (popup closed)
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Widgets.Switch {
                id: wifiToggle
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                widgetWidth: 50
                widgetHeight: 25
                toggleFunction: Services.Network.toggleWifi
                toggleState: Services.Network.wifiEnabled
            }

            Text {
                anchors {
                    left: wifiToggle.right
                    leftMargin: Globals.spacing
                    verticalCenter: parent.verticalCenter
                }
                color: Globals.theme.foreground
                font.pixelSize: Globals.fonts.medium
                font.family: Globals.theme.fontFamily
                text: Services.Network.wifiEnabled ? "Wi-Fi On" : "Wi-Fi Off"
            }

            Button {
                id: statusIndicator
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                background: Rectangle {
                    color: "transparent"
                }
                icon.source: root.hasProblem ? "../icons/warning.svg" : "../icons/reboot.svg"
                icon.width: Globals.fonts.large
                icon.height: Globals.fonts.large
                icon.color: root.indicatorColor
                enabled: false
            }
        }

        Text {
            Layout.fillWidth: true
            color: Services.Network.wifiConnected ? Globals.theme.accent1 : Globals.theme.muted
            font.pixelSize: Globals.fonts.small
            font.family: Globals.theme.fontFamily
            font.bold: Services.Network.wifiConnected
            elide: Text.ElideRight
            text: {
                if (!Services.Network.wifiEnabled)
                    return "Wi-Fi is disabled";
                if (Services.Network.ethernetConnected)
                    return "Connected via Ethernet";
                if (Services.Network.wifiConnected)
                    return "Connected to " + Services.Network.activeSsid;
                if (Services.Network.scanning)
                    return "Scanning...";
                if (root.hasProblem)
                    return "No Wi-Fi device";
                return "Not connected";
            }
        }

        ListView {
            id: networkListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Globals.padding
            clip: true
            model: Services.Network.wifiDevice?.networks ?? null

            displayMarginBeginning: -(2 * Globals.spacing)
            displayMarginEnd: -(2 * Globals.spacing)

            delegate: Item {
                id: delegateItem
                width: ListView.view.width
                height: 36

                readonly property bool isConnected: modelData.connected === true
                readonly property bool isConnecting: modelData.state === Net.ConnectionState.Connecting
                readonly property bool isKnown: modelData.known === true
                readonly property real signalStrength: modelData.signalStrength ?? 0

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (modelData.connected) {
                            modelData.disconnect();
                        } else {
                            modelData.connect();
                        }
                    }
                }

                Row {
                    id: signalBars
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        bottomMargin: (parent.height - 14) / 2   // 14 = tallest bar
                    }
                    spacing: 2

                    Repeater {
                        model: 4
                        Rectangle {
                            width: 3
                            height: 5 + index * 3   // 5, 8, 11, 14
                            radius: 1
                            anchors.bottom: parent.bottom
                            color: {
                                var threshold = (index + 1) * 0.22;
                                if (delegateItem.signalStrength >= threshold)
                                    return delegateItem.isConnected ? Globals.theme.accent1 : Globals.theme.foreground;
                                return Globals.theme.muted;
                            }
                        }
                    }
                }

                Text {
                    id: statusLabel
                    anchors {
                        right: parent.right
                        rightMargin: Globals.spacing
                        verticalCenter: parent.verticalCenter
                    }
                    color: delegateItem.isConnecting ? Globals.theme.accent1 : Globals.theme.muted
                    font.pixelSize: Globals.fonts.xsmall
                    font.family: Globals.theme.fontFamily
                    font.italic: delegateItem.isConnecting
                    text: {
                        if (delegateItem.isConnecting)
                            return "Connecting…";
                        var sec = modelData.security;
                        if (sec === undefined || sec === null || sec === Net.WifiSecurityType.Open)
                            return "";
                        return Net.WifiSecurityType.toString(sec);
                    }
                }

                Text {
                    anchors {
                        left: signalBars.right
                        leftMargin: Globals.spacing
                        right: statusLabel.left
                        rightMargin: Globals.spacing
                        verticalCenter: parent.verticalCenter
                    }
                    color: delegateItem.isConnected ? Globals.theme.accent1 : Globals.theme.foreground
                    font.pixelSize: Globals.fonts.medium
                    font.family: Globals.theme.fontFamily
                    font.bold: delegateItem.isConnected || delegateItem.isKnown
                    elide: Text.ElideRight
                    text: modelData.name || "(unnamed)"
                }
            }
        }
    }
}
