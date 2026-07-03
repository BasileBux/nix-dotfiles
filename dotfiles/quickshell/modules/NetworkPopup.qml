import Quickshell
import QtQuick
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

    function securityString(sec) {
        if (sec === undefined || sec === null || sec === Net.WifiSecurityType.Open) return "";
        return " (" + Net.WifiSecurityType.toString(sec) + ")";
    }

    function refreshNetworks() {
        const device = Services.Network.wifiDevice;
        const networks = device ? device.networks.values : [];

        const entries = networks.map(n => ({
            name: n.name,
            connected: n.connected,
            security: securityString(n.security),
            networkObj: n
        }));

        // Keep the list stable: connected first, then alphabetical by SSID.
        entries.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            return a.name.localeCompare(b.name);
        });

        networkListModel.clear();
        for (const e of entries) networkListModel.append(e);
    }

    Component.onCompleted: refreshNetworks()

    // Refreshes the list a few seconds after a rescan so new networks have
    // time to appear, without constantly rebuilding the list while scrolling.
    Timer {
        id: rescanResultTimer
        interval: 4000
        onTriggered: refreshNetworks()
    }

    ListModel {
        id: networkListModel
    }

    ColumnLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillWidth: true
            implicitHeight: 60
            Item {
                id: toggleInfo
                Layout.fillWidth: true
                implicitHeight: 30

                Widgets.Switch {
                    id: toggle
                    widgetWidth: 50
                    widgetHeight: widgetWidth / 2
                    toggleFunction: Services.Network.toggleWifi
                    toggleState: Services.Network.wifiEnabled
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    id: toggleText
                    color: Globals.theme.foreground
                    anchors {
                        left: toggle.right
                        verticalCenter: parent.verticalCenter
                    }
                    padding: Globals.spacing
                    font.pixelSize: Globals.fonts.medium
                    font.family: Globals.theme.fontFamily
                    text: Services.Network.wifiEnabled ? "On" : "Off"
                }

                Text {
                    id: activeInfo
                    color: Globals.theme.foreground
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    padding: Globals.spacing
                    font.pixelSize: Globals.fonts.medium
                    font.weight: Font.Bold
                    font.family: Globals.theme.fontFamily
                    text: {
                        if (Services.Network.scanning || !Services.Network.startupFinished)
                            return "Scanning...";
                        if (!Services.Network.wifiEnabled)
                            return "";
                        if (!Services.Network.hasActiveConnection)
                            return "Not connected";
                        if (Services.Network.ethernetConnected)
                            return "Ethernet connected";
                        return Services.Network.activeConnectionName;
                    }
                }
            }
            Item {
                id: rescanButton
                Layout.fillWidth: true
                implicitHeight: 30
                Text {
                    id: rescanText
                    anchors.bottom: parent.bottom
                    color: Globals.theme.foreground
                    font.pixelSize: Globals.fonts.large
                    font.weight: Font.Bold
                    font.family: Globals.theme.fontFamily
                    text: " "

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Services.Network.rescanWifi();
                            rescanResultTimer.restart();
                        }
                    }
                }
            }
        }

        Component {
            id: networkDelegate
            Item {
                id: item

                required property string name
                required property bool connected
                required property string security
                required property var networkObj

                height: 36
                width: networkListView.width

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (networkObj && networkObj.connected) {
                            networkObj.disconnect();
                        } else if (networkObj) {
                            networkObj.connect();
                        }
                    }
                }

                Text {
                    id: networkText
                    color: networkObj && networkObj.connected ? Globals.theme.accent1 : Globals.theme.foreground
                    font.pixelSize: Globals.fonts.medium
                    font.family: Globals.theme.fontFamily
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    elide: Text.ElideRight
                    text: item.name
                }
                Text {
                    id: securityText
                    color: Globals.theme.muted
                    font.pixelSize: Globals.fonts.small
                    font.family: Globals.theme.fontFamily
                    anchors {
                        right: parent.right
                        rightMargin: Globals.spacing
                        verticalCenter: parent.verticalCenter
                    }
                    text: item.security
                }
            }
        }

        Item {
            id: networksList
            Layout.fillWidth: true
            Layout.fillHeight: true
            ListView {
                id: networkListView
                anchors.fill: parent
                spacing: Globals.padding
                model: networkListModel

                delegate: networkDelegate

                displayMarginBeginning: -(2 * Globals.spacing)
                displayMarginEnd: -(2 * Globals.spacing)
            }
        }
    }
}
