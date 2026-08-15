pragma Singleton

import Quickshell
import QtQuick

Singleton {
    function getEnvOr(name, defaultValue) {
        var value = Quickshell.env(name);
        return value && value.length > 0 ? value : defaultValue;
    }

    property bool _soundReady: false
    readonly property int _startupGraceMs: 100

    Timer {
        interval: _startupGraceMs
        running: true
        repeat: false
        onTriggered: {
            _soundReady = true;
            playSound(sounds.unlock);
        }
    }

    function playSound(soundFile) {
        if (!_soundReady || !sounds.enabled)
            return;
        Quickshell.execDetached(["pw-play", "--volume", "0.35", sounds.path + soundFile]);
    }
    function playSoundLoud(soundFile) {
        if (!_soundReady || !sounds.enabled)
            return;
        Quickshell.execDetached(["pw-play", sounds.path + soundFile]);
    }

    readonly property int barWidth: 40
    readonly property int padding: 3
    readonly property int radius: 7
    readonly property int spacing: 6
    readonly property int barIconSpacing: 2

    readonly property int barExtrema: 4
    readonly property int workspacesGap: 5

    readonly property string terminal: "kitty"
    readonly property string browser: getEnvOr("WEB_BROWSER", "zen-twilight")

    readonly property var theme: Themes.modern.rodeurRouge

    // Semantic colors, consistent across all themes. Use these when a color needs
    // to convey meaning
    readonly property var colors: QtObject {
        readonly property color brightGreen: "#20FF4F"
        readonly property color green: "#008000"

        readonly property color red: "#FD788B"
    }

    readonly property var fonts: QtObject {
        readonly property int huge: 28
        readonly property int xlarge: 24
        readonly property int large: 18
        readonly property int medium: 14
        readonly property int small: 12
        readonly property int xsmall: 10
        readonly property int tiny: 8
    }

    readonly property var sounds: QtObject {
		readonly property bool enabled: true
        readonly property string path: Quickshell.shellDir + "/sounds/"

        readonly property string click: "click.wav"
        readonly property string toggleOn: "device-added.oga"
        readonly property string toggleOff: "device-removed.oga"
        readonly property string fancySelect: "fancy-select.wav"
        readonly property string pageTurn: "page.wav"
        readonly property string smallPing: "cute-confirm.wav"
        readonly property string bigPing: "starry-confirm.wav"
        readonly property string lock: "low-robotic-wave.ogg"
        readonly property string unlock: "startup.wav"
		readonly property string launch: "starry-confirm.wav"
    }

    readonly property int launcherWidth: 600
    readonly property int launcherHeight: 400

    readonly property var notification: QtObject {
        readonly property int unitWidth: 340
        readonly property int unitHeight: 100
        readonly property int maxVisible: 5
    }

    readonly property int authDialogWidth: 380
    readonly property int authDialogHeight: 200

    readonly property var extras: QtObject {
        readonly property int remoteWidth: 440
        readonly property int remoteHeight: 420
        readonly property string remoteDefaultTmuxSession: "main"
    }

    readonly property string machine: getEnvOr("QUICKSHELL_MACHINE", "simon")
}
