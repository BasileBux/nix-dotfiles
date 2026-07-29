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
        leftMargin: Globals.spacing * 2
        rightMargin: Globals.spacing * 2
        bottomMargin: Globals.spacing
    }

    required property int popupWidth
    required property var moduleRef

    readonly property real percentage: UPower.displayDevice.percentage
    readonly property bool isLow: percentage <= 0.20

    function formatTime(seconds) {
        if (seconds <= 0)
            return "";
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        if (h > 0)
            return h + "h " + String(m).padStart(2, "0") + "m";
        return m + "m";
    }

    property int activeProfileIndex: 1

	onActiveProfileIndexChanged: {
		Globals.playSound(Globals.sounds.fancySelect);
	}

    Component.onCompleted: currentProfileProcess.running = true

    function setProfile(index) {
        if (index === activeProfileIndex)
            return;
        activeProfileIndex = index;
        profileProcs[index].running = true;
        refetchTimer.restart();
    }

    // Pill x: the pill is a child of track, so x is relative to track's left
    // edge.  activeProfileIndex * (bw + bs) gives the button offset within
    // the buttonRow; Globals.spacing is track padding; (pw - bw) / 2 centres
    // the pill over the button.
    readonly property int bw: 56   // button item width
    readonly property int bs: 2    // button spacing
    readonly property int pw: 62   // pill width
    readonly property real pillX: Globals.spacing + root.activeProfileIndex * (bw + bs) - (pw - bw) / 2

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        // Percentage
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: (root.percentage * 100).toFixed(0) + "%"
            color: root.isLow ? Globals.colors.red : moduleRef.isCharging ? Globals.colors.green : Globals.theme.foreground
            font.pixelSize: Globals.fonts.xlarge
            font.family: Globals.theme.fontFamily
            font.bold: true
        }

        // Status
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: {
                if (moduleRef.isDocked)
                    return "Docked";
                var rate = Math.abs(UPower.displayDevice.changeRate).toFixed(1);
                return (moduleRef.isCharging ? "Charging" : "Discharging") + " · " + rate + " W";
            }
            color: Globals.theme.muted
            font.pixelSize: Globals.fonts.small
            font.family: Globals.theme.fontFamily
        }

        // Time estimate
        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: !moduleRef.isDocked
            color: Globals.theme.muted
            font.pixelSize: Globals.fonts.xsmall
            font.family: Globals.theme.fontFamily
            text: {
                var s = moduleRef.isCharging ? UPower.displayDevice.timeToFull : UPower.displayDevice.timeToEmpty;
                var t = root.formatTime(s);
                if (t === "")
                    return "Estimating…";
                return moduleRef.isCharging ? "Full in " + t : "Empty in " + t;
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            color: Globals.theme.border
            opacity: 0.2
        }

        // Power profile selector
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 34

            Item {
                id: track
                anchors.centerIn: parent
                width: buttonRow.width + Globals.spacing * 2
                height: parent.height

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Globals.theme.muted
                    opacity: 0.4
                }

                Rectangle {
                    id: pill
                    width: root.pw
                    height: track.height - 4
                    radius: height / 2
                    color: Globals.theme.accent1
                    y: 2
                    x: root.pillX

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            Row {
                id: buttonRow
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    id: profileButtons
                    model: [
                        {
                            icon: "../icons/leaf.svg",
                            iw: 27,
                            ih: 27,
                            idx: 0
                        },
                        {
                            icon: "../icons/balance.svg",
                            iw: 29,
                            ih: 29,
                            idx: 1
                        },
                        {
                            icon: "../icons/rocket.svg",
                            iw: 26,
                            ih: 26,
                            idx: 2
                        },
                    ]
                    delegate: Item {
                        width: 56
                        height: track.height
                        Widgets.TintIcon {
                            anchors.centerIn: parent
                            source: modelData.icon
                            width: modelData.iw
                            height: modelData.ih
                            color: root.activeProfileIndex === modelData.idx ? Globals.theme.background : Globals.theme.foreground
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.setProfile(modelData.idx)
                        }
                    }
                }
            }
        }

        // Hypridle toggle
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 25

            RowLayout {
                spacing: 0
                anchors.fill: parent

                property bool hypridleState: true

                Component.onCompleted: {
                    hypridleState = false;
                    Quickshell.execDetached({
                        command: Machines.current.hypridleStopCommand
                    });
                    hypridleSwitch.silent = false;
                }

                Widgets.Switch {
                    id: hypridleSwitch
                    widgetWidth: 45
                    widgetHeight: 22
                    toggleFunction: () => {
                        parent.hypridleState = !parent.hypridleState;
                        Quickshell.execDetached({
                            command: parent.hypridleState ? Machines.current.hypridleStartCommand : Machines.current.hypridleStopCommand
                        });
                    }
                    toggleState: parent.hypridleState
                    silent: true
                }

                Text {
                    color: Globals.theme.foreground
                    font.pixelSize: Globals.fonts.small
                    font.family: Globals.theme.fontFamily
                    leftPadding: Globals.spacing
                    text: (parent.hypridleState ? "On" : "Off") + " · hypridle"
                }
            }
        }
    }

    // Processes
    property var profileProcs: [ecoProc, balancedProc, perfProc]

    Process {
        id: ecoProc
        command: Machines.current.ecoCommand
        running: false
    }
    Process {
        id: balancedProc
        command: Machines.current.balancedCommand
        running: false
    }
    Process {
        id: perfProc
        command: Machines.current.performanceCommand
        running: false
    }

    Process {
        id: currentProfileProcess
        command: Machines.current.getterCommand
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var name = this.text.split(" ")[Machines.current.getterStringSplitIndex].split("\n")[0].trim();
                var idx = Machines.current.profiles.indexOf(name);
                root.activeProfileIndex = idx >= 0 ? idx : 1;
                if (idx < 0)
                    root.profileProcs[1].running = true;
            }
        }
    }

    Timer {
        id: refetchTimer
        interval: 200
        repeat: false
        running: false
        onTriggered: currentProfileProcess.running = true
    }
}
