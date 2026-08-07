pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property var profiles: ["power-saver", "balanced", "performance"]
    readonly property var setCommand: ["powerprofilesctl", "set"]

    readonly property var ecoCommand: setCommand.concat([profiles[0]])
    readonly property var balancedCommand: setCommand.concat([profiles[1]])
    readonly property var performanceCommand: setCommand.concat([profiles[2]])
    readonly property var getterCommand: ["powerprofilesctl", "get"]
}
