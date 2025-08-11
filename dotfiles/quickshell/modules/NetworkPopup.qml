import Quickshell
import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "../widgets" as Widgets
import ".."

Item {
    id: root
    anchors.fill: parent
    anchors.topMargin: Globals.spacing
    anchors.leftMargin: Globals.spacing

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
                    widgetWidth: 60
                    widgetHeight: 30
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
                    text: {
                        if (Services.Network.scanning || !Services.Network.startupFinished)
                            return "Scanning...";
                        if (!Services.Network.wifiEnabled)
                            return "";
                        if (!Services.Network.active)
                            return "Not connected";
                        if (Services.Network.ethernetConnected)
                            return "Ethernet connected";
                        return Services.Network.active.ssid;
                    }
                }
            }
            Item {
                id: rescanButton
                Layout.fillWidth: true
                implicitHeight: 30
                Text {
                    id: rescanText
                    // leftPadding: Globals.spacing
                    anchors.bottom: parent.bottom
                    color: Globals.theme.foreground
                    font.pixelSize: Globals.fonts.large
                    font.weight: Font.Bold
                    text: " "

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Services.Network.rescanWifi();
                        }
                        onEntered: {
                            rescanText.color = Globals.theme.accent2;
                        }
                        onExited: {
                            rescanText.color = Globals.theme.foreground;
                        }
                    }
                }
            }
        }

        Component {
            id: networkDelegate
            Item {
                id: item

                required property string ssid
                required property bool active
                required property string security

                height: 36
                width: parent.width

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        networkText.color = Globals.theme.accent2;
                    }
                    onExited: {
                        networkText.color = item.active ? Globals.theme.accent1 : Globals.theme.foreground;
                    }
                    onClicked: {
                        if (item.active) {
                            Services.Network.disconnectFromNetwork();
                            return;
                        }
                        Services.Network.connectToNetwork(item.ssid);
                    }
                }

                Text {
                    id: networkText
                    color: item.active ? Globals.theme.accent1 : Globals.theme.foreground
                    font.pixelSize: Globals.fonts.medium
                    anchors {
                        left: parent.left
                        // leftMargin: Globals.spacing
                        verticalCenter: parent.verticalCenter
                    }
                    text: item.ssid
                }
                Text {
                    id: securityText
                    color: Globals.theme.foreground
                    font.pixelSize: Globals.fonts.small
                    anchors {
                        right: parent.right
                        rightMargin: Globals.spacing
                        verticalCenter: parent.verticalCenter
                    }
                    text: item.security ? " (" + item.security + ")" : ""
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
                model: Services.Network.networks

                delegate: networkDelegate

                displayMarginBeginning: -(2 * Globals.spacing)
                displayMarginEnd: -(2 * Globals.spacing)
            }
        }
    }
}
