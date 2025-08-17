import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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

    property int popupWidth
    property var moduleRef

    ColumnLayout {
        spacing: Globals.padding
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                id: textInfoLayout
                spacing: 0
                anchors.fill: parent
                Text {
                    id: powerText
                    Layout.alignment: Qt.AlignTop
                    text: moduleRef.isDocked ? "Device is docked" : moduleRef.isCharging ? "Charging at: " + (UPower.displayDevice.changeRate).toFixed(2) + " W" : "Discharging at: " + (UPower.displayDevice.changeRate).toFixed(2) + " W"
                    color: Globals.theme.foreground
                    font.pointSize: Globals.fonts.small
                    font.bold: true
                    Layout.bottomMargin: -Globals.spacing
                }

                Text {
                    id: currentProfileText
                    Layout.alignment: Qt.AlignTop
                    property string timeTo: {
                        var time = root.moduleRef.isCharging ? UPower.displayDevice.timeToFull : UPower.displayDevice.timeToEmpty;
                        var ret = Math.floor(time / 3600) + "h" + Math.floor((time % 3600) / 60);
                        return ret;
                    }
                    text: root.moduleRef.isDocked ? "No battery change" : widgetRef.isCharging ? "Battery full in: " + timeTo : "Battery empty in: " + timeTo
                    color: Globals.theme.foreground
                    font.pointSize: Globals.fonts.small
                }

                RowLayout {
                    id: hypridle
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    property bool hypridleState: true

                    Widgets.Switch {
                        id: hypridleSwitch
                        widgetWidth: 40
                        widgetHeight: 20
                        toggleFunction: () => {
                            if (hypridle.hypridleState) {
                                Quickshell.execDetached({
                                    command: Machines.current.hypridleStopCommand,
                                });
                            } else {
                                Quickshell.execDetached({
                                    command: Machines.current.hypridleStartCommand,
                                });
                            }
                            hypridle.hypridleState = !hypridle.hypridleState;
                        }
                        toggleState: hypridle.hypridleState
                    }
                    Text {
                        id: toggleText
                        color: Globals.theme.foreground
                        font.pixelSize: Globals.fonts.medium
                        text: (hypridle.hypridleState ? "On" : "Off") + " - hypridle"
                    }
                }
            }
        }

        Item {
            id: powerProfile
            implicitHeight: 80
            Layout.fillWidth: true

            property string currentProfile

            state: "balanced"
            states: [
                State {
                    name: "eco"
                    PropertyChanges {
                        selector.x: root.width / 2 - selector.width / 2 - profiles.buttonSize * 2
                        ecoButton.icon.color: Globals.theme.accent1
                    }
                },
                State {
                    name: "balanced"
                    PropertyChanges {
                        selector.x: root.width / 2 - selector.width / 2
                        balancedButton.icon.color: Globals.theme.accent1
                    }
                },
                State {
                    name: "performance"
                    PropertyChanges {
                        selector.x: root.width / 2 - selector.width / 2 + profiles.buttonSize * 2
                        performanceButton.icon.color: Globals.theme.accent1
                    }
                }
            ]

            transitions: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        target: selector
                        property: "x"
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Rectangle {
                id: background
                color: Globals.theme.accent1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 5 * profiles.buttonSize + 2 * Globals.spacing
                implicitHeight: profiles.buttonSize + Globals.spacing * 2
                radius: profiles.buttonSize / 2 + Globals.spacing
            }
            Rectangle {
                id: selector
                color: Globals.theme.accent2
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: profiles.buttonSize
                implicitHeight: profiles.buttonSize
                radius: profiles.buttonSize / 2
            }
            RowLayout {
                id: profiles
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                property int buttonSize: 50
                spacing: buttonSize
                uniformCellSizes: true
                Item {
                    id: eco
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: parent.buttonSize
                    implicitHeight: parent.buttonSize
                    Button {
                        id: ecoButton
                        background: Rectangle {
                            color: "transparent"
                        }
                        anchors.fill: parent
                        icon.source: "../icons/leaf.svg"
                        icon.width: parent.implicitWidth * 0.75
                        icon.height: parent.implicitWidth * 0.75
                        icon.color: Globals.theme.muted
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            powerProfile.state = "eco";
                            ecoProcess.running = true;
                            paddingTimer.running = true;
                        }
                    }
                }
                Item {
                    id: balanced
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: parent.buttonSize
                    implicitHeight: parent.buttonSize
                    Button {
                        id: balancedButton
                        background: Rectangle {
                            color: "transparent"
                        }
                        anchors.fill: parent
                        icon.source: "../icons/balance.svg"
                        icon.width: parent.implicitWidth * 0.8
                        icon.height: parent.implicitWidth * 0.8
                        icon.color: Globals.theme.muted
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            powerProfile.state = "balanced";
                            balancedProcess.running = true;
                            paddingTimer.running = true;
                        }
                    }
                }
                Item {
                    id: performance
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: parent.buttonSize
                    implicitHeight: parent.buttonSize
                    Button {
                        id: performanceButton
                        background: Rectangle {
                            color: "transparent"
                        }
                        anchors.fill: parent
                        icon.source: "../icons/rocket.svg"
                        icon.width: parent.implicitWidth * 0.65
                        icon.height: parent.implicitWidth * 0.65
                        icon.color: Globals.theme.muted
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            powerProfile.state = "performance";
                            performanceProcess.running = true;
                            paddingTimer.running = true;
                        }
                    }
                }
            }
        }
    }
    Process {
        id: ecoProcess
        command: Machines.current.ecoCommand
        running: false
    }
    Process {
        id: balancedProcess
        command: Machines.current.balancedCommand
        running: false
    }
    Process {
        id: performanceProcess
        command: Machines.current.performanceCommand
        running: false
    }
    Process {
        id: currentProfileProcess
        command: Machines.current.getterCommand
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                powerProfile.currentProfile = this.text.split(" ")[Machines.current.getterStringSplitIndex].trim();
            }
        }
    }
    Process {
        id: init
        command: Machines.current.getterCommand
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                powerProfile.currentProfile = this.text.split(" ")[Machines.current.getterStringSplitIndex].trim();
                if (powerProfile.currentProfile === Machines.current.profiles[0]) {
                    powerProfile.state = "eco";
                } else if (powerProfile.currentProfile === Machines.current.profiles[1]) {
                    powerProfile.state = "balanced";
                } else if (powerProfile.currentProfile === Machines.current.profiles[2]) {
                    powerProfile.state = "performance";
                } else {
                    powerProfile.state = "balanced";
                    balancedProcess.running = true;
                }
            }
        }
    }
    Timer {
        id: paddingTimer
        interval: 100
        repeat: false
        running: false
        onTriggered: {
            currentProfileProcess.running = true;
        }
    }
}
