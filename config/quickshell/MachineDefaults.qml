pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // Mirrors modules/quickshell.mod.nix (remoteHosts): used only in standalone
    // mode, when the Nix-generated MachineOverrides.qml is absent.
    readonly property var remoteHosts: [
        {
            name: "kamina",
            target: "kamina",
            role: "Desktop · VM host",
            allowPower: true
        },
        {
            name: "genome",
            target: "genome",
            role: "Home server (RPi5)",
            allowPower: true
        },
        {
            name: "yoko",
            target: "yoko",
            role: "VPS · asbel.xyz",
            allowPower: false
        },
        {
            name: "buxtorf-synology",
            target: "buxtorf-synology",
            role: "NAS",
            allowPower: false,
            tmux: false
        }
    ]
    readonly property var balancedCommand: setCommand.concat([profiles[1]])
    readonly property var ecoCommand: setCommand.concat([profiles[0]])
    readonly property var getterCommand: ["powerprofilesctl", "get"]
    readonly property var performanceCommand: setCommand.concat([profiles[2]])
    readonly property var profiles: ["power-saver", "balanced", "performance"]
    readonly property var setCommand: ["powerprofilesctl", "set"]
}
