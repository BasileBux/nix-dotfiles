pragma Singleton

import Quickshell
import QtQuick

Singleton {

    // Machine and environment
    readonly property string machine: getEnvOr("QUICKSHELL_MACHINE", "simon")
    readonly property string browser: getEnvOr("WEB_BROWSER", "zen-twilight")
    readonly property string terminal: "kitty"

    // Unset Qt-specific env vars when launching foreign apps: they can cause
    // version conflicts with apps that bundle their own Qt.
    readonly property var cleanEnv: ({
            QT_PLUGIN_PATH: null,
            NIXPKGS_QT6_QML_IMPORT_PATH: null
        })

    // Theme and colors
    readonly property var theme: Themes.modern.rodeurRouge

    // Semantic colors, consistent across all themes. Use these when a color needs to convey meaning.
    // A state word ("Connected", "On") is always rendered in the foreground; these
    // appear only as a dot, an icon or a bar.
    readonly property var colors: QtObject {
        readonly property color danger: "#FF6B6B"
        readonly property color dangerText: "#FF9E9E"
        readonly property color success: "#57DB87"
        readonly property color warning: "#F5B544"
    }

    // Periwinkle for selection, controls and ordinary data; alarms stay semantic.
    readonly property color accent: "#96A7FF"
    // Content colour on a solid accent fill.
    readonly property color accentContent: "#0B0D14"

    // Opaque tonal ramp: for the few surfaces that are not alpha-based (popovers,
    // drop targets). An element is either alpha-based or ramp-based, never both.
    readonly property color tone0: "#0A0C11"
    readonly property color tone1: "#14171F"
    readonly property color tone2: "#1B1F28"
    readonly property color tone3: "#232833"
    readonly property color tone4: "#2C3240"

    // Surfaces: one elevation system. L1 card, L2 raised, L3 well.
    readonly property color surface: Qt.rgba(1, 1, 1, 0.04)
    readonly property color surfaceBorder: Qt.rgba(1, 1, 1, 0.10)
    readonly property color surfaceHover: Qt.rgba(1, 1, 1, 0.09)
    readonly property color surfacePressed: Qt.rgba(1, 1, 1, 0.12)
    readonly property color surfaceHoverBorder: Qt.rgba(1, 1, 1, 0.16)
    readonly property color well: Qt.rgba(0, 0, 0, 0.22)
    readonly property color wellBorder: Qt.rgba(0, 0, 0, 0.30)
    readonly property color controlTrack: "#454852"
    readonly property color controlBorder: "#747985"
    // Fixed scrim behind the glass. Must stay in [0.72, 0.82]: Hyprland's layer
    // blur has ignore_alpha = 0.5, so anything thinner renders the wallpaper
    // pin-sharp under the glyphs and body text drops below 4.5:1.
    readonly property color surfaceBackground: Qt.rgba(theme.background.r, theme.background.g, theme.background.b, 0.78)
    readonly property color accentFill: Qt.rgba(accent.r, accent.g, accent.b, 0.16)

    // Motion. Feedback lives inside the surface, never on the window.
    readonly property int motionHover: 110
    readonly property int motionPress: 90
    readonly property int motionSettle: 120
    readonly property int motionPill: 160

    // Typography
    readonly property var fonts: QtObject {
        readonly property int display: 56
        readonly property int clock: 28
        readonly property int metric: 28
        readonly property int title: 20
        readonly property int lead: 16
        readonly property int body: 14
        readonly property int caption: 12
        readonly property int micro: 10
    }

    // Spacing scale. Every margin/padding/spacing in the tree is one of these.
    readonly property int space1: 4
    readonly property int space2: 8
    readonly property int margin: 16
    readonly property int space4: 24
    // Edge-to-edge: a permitted exception, not a step on the scale.
    readonly property int flush: 0

    // Corner radius. Inner radius = outer radius - inset, at every nesting level.
    // Anything that cannot satisfy that is a pill (height / 2) or flush.
    readonly property int radius: 8
    readonly property int cardRadius: 16
    readonly property int paletteRadius: 32

    readonly property int authDialogHeight: 200
    readonly property int authDialogWidth: 380

    readonly property var notification: QtObject {
        readonly property int maxVisible: 5
        // Fallback expire timeout when the server sends none (0 = never expire).
        readonly property int timeoutMs: 5000
        readonly property int unitHeight: 100
        readonly property int unitWidth: 340
    }

    // Sounds
    property bool _soundReady: false
    readonly property int _startupGraceMs: 100

    readonly property var sounds: QtObject {
        readonly property string path: Quickshell.shellDir + "/sounds/"
        readonly property bool enabled: true

        readonly property string bigPing: "starry-confirm.wav"
        readonly property string smallPing: "cute-confirm.wav"
        readonly property string click: "click.wav"
        readonly property string fancySelect: "fancy-select.wav"
        readonly property string launch: "starry-confirm.wav"
        readonly property string pageTurn: "page.wav"
        readonly property string toggleOn: "device-added.oga"
        readonly property string toggleOff: "device-removed.oga"
        readonly property string lock: "low-robotic-wave.ogg"
        readonly property string unlock: "startup.wav"
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

    Timer {
        interval: _startupGraceMs
        repeat: false
        running: true

        onTriggered: {
            _soundReady = true;
            playSound(sounds.unlock);
        }
    }

    // Helpers
    function getEnvOr(name, defaultValue) {
        var value = Quickshell.env(name);
        return value && value.length > 0 ? value : defaultValue;
    }
    function percent(value) {
        return Math.round(value * 100) + "%";
    }
}
