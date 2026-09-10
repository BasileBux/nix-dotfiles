import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "../../services" as Services
import "../widgets" as PWidgets
import "../../widgets" as Widgets
import "../.."

Item {
    id: root

    property int activeProfileIndex: 1
    // The hypridle daemon is stopped at startup, so the switch starts off.
    property bool hypridleState: false
    readonly property var chargeState: UPower.displayDevice.state
    readonly property bool isCharging: chargeState == UPowerDeviceState.Charging
    readonly property bool isDocked: chargeState != UPowerDeviceState.Charging && UPower.displayDevice.changeRate <= 0.01
    readonly property bool isLow: !isCharging && percentage <= 0.20
    readonly property real percentage: UPower.displayDevice.percentage
    readonly property var profileIcons: [
        {
            icon: "leaf",
            label: "Eco"
        },
        {
            icon: "balance",
            label: "Balanced"
        },
        {
            icon: "rocket",
            label: "Performance"
        }
    ]

    // Processes
    property var profileProcs: [ecoProc, balancedProc, perfProc]

    // Battery facts line: Wh in the tank, health and pack temperature.
    readonly property string factsText: {
        var d = UPower.displayDevice;
        var parts = [];
        if (d.energyCapacity > 0)
            parts.push(d.energy.toFixed(0) + " / " + d.energyCapacity.toFixed(0) + " Wh");
        if (d.healthSupported && d.healthPercentage > 0)
            parts.push("Health " + Math.round(d.healthPercentage) + "%");
        return parts.join(" · ");
    }

    onVisibleChanged: {
        Services.SystemStats.polling = visible;
        if (visible)
            Services.SystemStats.refresh();
    }

    function handleKey(event) {
        if (event.key === Qt.Key_Left) {
            root.setProfile(Math.max(0, root.activeProfileIndex - 1));
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            root.setProfile(Math.min(root.profileProcs.length - 1, root.activeProfileIndex + 1));
            event.accepted = true;
        }
    }

    function barColor(ratio, warning, critical) {
        return ratio >= critical ? Globals.colors.danger : ratio >= warning ? Globals.colors.warning : Globals.accent;
    }
    function fmtGb(gb) {
        return gb >= 100 ? Math.round(gb) + " GB" : gb.toFixed(1) + " GB";
    }
    function formatTime(seconds) {
        if (seconds <= 0)
            return "";
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        if (h > 0)
            return h + "h " + String(m).padStart(2, "0") + "m";
        return m + "m";
    }
    function setProfile(index) {
        if (index === activeProfileIndex)
            return;
        activeProfileIndex = index;
        profileProcs[index].running = true;
        refetchTimer.restart();
    }

    // Stat card: icon + label left, value right, one semantic track underneath.
    component StatCard: PWidgets.Surface {
        id: statCard

        property string iconName
        property string label
        property string value
        default property alias visual: visualHolder.data

        Layout.preferredHeight: 84
        Layout.preferredWidth: 328
        cornerRadius: Globals.radius

        ColumnLayout {
            anchors.fill: parent
            spacing: Globals.space2

            RowLayout {
                Layout.fillWidth: true
                spacing: Globals.space1

                Widgets.TintIcon {
                    Layout.preferredHeight: 20
                    Layout.preferredWidth: 20
                    color: Globals.theme.muted
                    name: statCard.iconName
                }
                Text {
                    Layout.fillWidth: true
                    color: Globals.theme.muted
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    text: statCard.label
                }
                Text {
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.features: {
                        "tnum": 1
                    }
                    font.pixelSize: Globals.fonts.caption
                    text: statCard.value
                }
            }
            Item {
                id: visualHolder

                Layout.fillWidth: true
                Layout.preferredHeight: 18
            }
        }
    }
    // Recessed 6 px track with a semantic fill: data follows the bar with no lag.
    component StatTrack: Rectangle {
        property real ratio: 0
        property color barColor: Globals.accent

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: Globals.well
        height: 6
        radius: 3

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            color: parent.barColor
            radius: 3
            width: parent.width * Math.min(parent.ratio, 1)
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: Globals.space2

        ColumnLayout {
            anchors.fill: parent
            spacing: Globals.space2

            // Hero: the ring, the number, the state, the pack figures.
            PWidgets.Surface {
                Layout.fillWidth: true
                Layout.preferredHeight: 116
                level: 3
                padding: Globals.margin
                cornerRadius: Globals.radius

                RowLayout {
                    anchors.fill: parent
                    spacing: Globals.margin

                    Item {
                        Layout.preferredHeight: 84
                        Layout.preferredWidth: 84

                        PWidgets.BatteryRing {
                            anchors.fill: parent
                            charging: root.isCharging
                            level: root.percentage
                            thickness: 8
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Globals.space1

                        Text {
                            color: root.percentage <= 0.15 ? Globals.colors.danger : Globals.theme.foreground
                            font.family: Globals.theme.fontFamily
                            font.features: {
                                "tnum": 1
                            }
                            font.pixelSize: Globals.fonts.metric
                            font.weight: Font.DemiBold
                            text: (root.percentage * 100).toFixed(0) + "%"
                        }
                        Text {
                            color: Globals.theme.foreground
                            font.family: Globals.theme.fontFamily
                            font.pixelSize: Globals.fonts.caption
                            text: {
                                if (root.isDocked)
                                    return "Docked";
                                var rate = Math.abs(UPower.displayDevice.changeRate).toFixed(1);
                                return (root.isCharging ? "Charging" : "Discharging") + " · " + rate + " W";
                            }
                        }
                        Text {
                            color: Globals.theme.muted
                            font.family: Globals.theme.fontFamily
                            font.pixelSize: Globals.fonts.micro
                            text: {
                                var s = root.isCharging ? UPower.displayDevice.timeToFull : UPower.displayDevice.timeToEmpty;
                                var t = root.formatTime(s);
                                if (t === "")
                                    return "Estimating…";
                                return root.isCharging ? "Full in " + t : "Empty in " + t;
                            }
                            visible: !root.isDocked
                        }
                        Text {
                            color: Globals.theme.muted
                            font.family: Globals.theme.fontFamily
                            font.features: {
                                "tnum": 1
                            }
                            font.pixelSize: Globals.fonts.micro
                            text: root.factsText
                            visible: root.factsText.length > 0
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: Globals.space1

                        PWidgets.SectionLabel {
                            Layout.alignment: Qt.AlignRight
                            label: "Uptime"
                        }
                        Text {
                            Layout.alignment: Qt.AlignRight
                            color: Globals.theme.foreground
                            font.family: Globals.theme.fontFamily
                            font.features: {
                                "tnum": 1
                            }
                            font.pixelSize: Globals.fonts.caption
                            text: Services.SystemStats.uptimeText
                        }
                        Text {
                            Layout.alignment: Qt.AlignRight
                            color: Globals.theme.muted
                            font.family: Globals.theme.fontFamily
                            font.features: {
                                "tnum": 1
                            }
                            font.pixelSize: Globals.fonts.micro
                            text: "LOAD " + Services.SystemStats.load1.toFixed(2) + " · " + Services.SystemStats.load5.toFixed(2) + " · " + Services.SystemStats.load15.toFixed(2)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Globals.margin

                StatCard {
                    iconName: "cpu"
                    label: "CPU · per core"
                    value: {
                        var s = Math.round(Services.SystemStats.cpu * 100) + "%";
                        if (Services.SystemStats.hasTemp)
                            s += " · " + Math.round(Services.SystemStats.tempC) + "°C";
                        return s;
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: Globals.space1

                        Repeater {
                            model: Services.SystemStats.cores.length

                            Item {
                                property real u: Services.SystemStats.cores[index] ?? 0

                                Layout.fillWidth: true
                                Layout.preferredHeight: 18

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    color: Globals.accent
                                    height: Math.max(1, 18 * parent.u)
                                    radius: 1
                                }
                            }
                        }
                    }
                }
                StatCard {
                    iconName: "memory"
                    label: "RAM"
                    value: root.fmtGb(Services.SystemStats.memUsedGb) + " / " + root.fmtGb(Services.SystemStats.memTotalGb)

                    StatTrack {
                        barColor: root.barColor(Services.SystemStats.memPct, 0.8, 0.95)
                        ratio: Services.SystemStats.memPct
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Globals.margin

                StatCard {
                    iconName: "drive"
                    label: "Disk"
                    value: root.fmtGb(Services.SystemStats.diskUsedGb) + " / " + root.fmtGb(Services.SystemStats.diskTotalGb)

                    StatTrack {
                        barColor: root.barColor(Services.SystemStats.diskPct, 0.8, 0.95)
                        ratio: Services.SystemStats.diskPct
                    }
                }
                StatCard {
                    iconName: "thermometer"
                    label: "Temp"
                    value: Services.SystemStats.hasTemp ? Math.round(Services.SystemStats.tempC) + "°C" : "—"

                    StatTrack {
                        barColor: root.barColor(Services.SystemStats.tempC, 80, 95)
                        ratio: Math.min(Services.SystemStats.tempC / 100, 1)
                    }
                }
            }

            // Power profile: three-way segmented control, the pill travels.
            PWidgets.Surface {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 44
                Layout.preferredWidth: 480
                level: 3
                padding: Globals.space1
                pill: true

                Item {
                    id: segmentTrack

                    anchors.fill: parent

                    Rectangle {
                        id: segmentPill

                        color: Globals.accent
                        height: parent.height
                        radius: height / 2
                        width: segmentTrack.width / 3
                        x: root.activeProfileIndex * width

                        Behavior on x {
                            NumberAnimation {
                                duration: Globals.motionPill
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                    RowLayout {
                        anchors.fill: parent
                        spacing: Globals.flush

                        Repeater {
                            model: root.profileIcons

                            delegate: Item {
                                id: segment

                                readonly property bool active: root.activeProfileIndex === index
                                readonly property bool hovered: segmentMa.containsMouse
                                required property int index
                                required property var modelData

                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: Globals.flush
                                    color: segment.hovered && !segment.active ? Globals.surfaceHover : "transparent"
                                    radius: height / 2
                                }
                                Row {
                                    anchors.centerIn: parent
                                    spacing: Globals.space2
                                    Widgets.TintIcon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: segment.active ? Globals.accentContent : Globals.theme.foreground
                                        height: 22
                                        width: 22
                                        name: segment.modelData.icon
                                    }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: segment.modelData.label
                                        color: segment.active ? Globals.accentContent : Globals.theme.foreground
                                        font.family: Globals.theme.fontFamily
                                        font.pixelSize: Globals.fonts.body
                                        font.weight: Font.Medium
                                    }
                                }
                                MouseArea {
                                    id: segmentMa

                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true

                                    onClicked: root.setProfile(segment.index)
                                }
                            }
                        }
                    }
                }
            }

            // Hypridle toggle
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                spacing: Globals.space2

                Widgets.Switch {
                    id: hypridleSwitch

                    silent: true
                    toggleFunction: () => {
                        root.hypridleState = !root.hypridleState;
                        Quickshell.execDetached({
                            command: root.hypridleState ? Machines.hypridleStartCommand : Machines.hypridleStopCommand
                        });
                    }
                    toggleState: root.hypridleState
                }
                Text {
                    color: Globals.theme.foreground
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    text: "Automatic idle locking · " + (root.hypridleState ? "On" : "Off")
                }
                Item {
                    Layout.fillWidth: true
                }
            }

            // All leftover space pools here, below the controls.
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

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
                // Search for the longest matching profile name in the output.
                // Sorted descending to avoid "balanced" matching before "balanced-performance".
                var sorted = Machines.current.profiles.slice().sort((a, b) => b.length - a.length);
                var idx = -1;
                for (var i = 0; i < sorted.length; i++) {
                    if (this.text.includes(sorted[i])) {
                        idx = Machines.current.profiles.indexOf(sorted[i]);
                        break;
                    }
                }
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
    Component.onCompleted: {
        // Mirrors the old inline initialisation: the daemon is stopped at startup
        // and the switch must not play a toggle sound for that.
        root.hypridleState = false;
        Quickshell.execDetached({
            command: Machines.hypridleStopCommand
        });
        hypridleSwitch.silent = false;
    }
}
