pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property var current: Globals.machine === "asus" ? asus : Globals.machine === "thinkpad" ? thinkpad : null

    readonly property var asus: QtObject {
        readonly property var profiles: ["Quiet", "Balanced", "Performance"]
        readonly property var getterCommand: ["asusctl", "profile", "-p"]
        readonly property int getterStringSplitIndex: 5
        readonly property var ecoCommand: ["asusctl", "profile", "-P", "Quiet"]
        readonly property var balancedCommand: ["asusctl", "profile", "-P", "Balanced"]
        readonly property var performanceCommand: ["asusctl", "profile", "-P", "Performance"]
        readonly property var hypridleStartCommand: ["systemctl", "--user", "start", "hypridle"]
        readonly property var hypridleStopCommand: ["systemctl", "--user", "stop", "hypridle"]
    }

    readonly property var thinkpad: QtObject {
        readonly property var profiles: ["powersave", "balanced", "desktop"]
        readonly property var getterCommand: ["tuned-adm", "active"]
        readonly property int getterStringSplitIndex: 3
        readonly property var ecoCommand: ["tuned-adm", "profile", "powersave"]
        readonly property var balancedCommand: ["tuned-adm", "profile", "balanced"]
        readonly property var performanceCommand: ["tuned-adm", "profile", "desktop"]
        readonly property var hypridleStartCommand: ["hypridle"]
        readonly property var hypridleStopCommand: ["pkill", "hypridle"]
    }
}
