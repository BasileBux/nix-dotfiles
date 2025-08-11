pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property int barWidth: 70
    readonly property int padding: 3
    readonly property int radius: 7
    readonly property int spacing: 6

    readonly property string popup: "Popup"

    readonly property int barExtrema: 8
    readonly property int workspacesGap: 5

    readonly property string terminal: "ghostty"
    readonly property string browser: "zen-twilight"

    readonly property var theme: antidote

    readonly property var megalinee: QtObject {
        readonly property color background: "#0a000a"
        readonly property color foreground: "#ECEFF4"
        readonly property color accent1: "#F970CD"
        readonly property color accent2: "#381254"
        readonly property color accent3: "#20FF4F"
        readonly property color border: "#4C566A"
        readonly property color muted: "#3b033b"
        readonly property string wallpaper: "wallpapers/megalinee.png"
    }

    readonly property var antidote: QtObject {
        readonly property color background: "#DCE2F2"
        readonly property color foreground: "#808FD6"
        readonly property color accent3: "#E057F2"
        readonly property color accent2: "#D4A7E4"
        readonly property color accent1: "#9B49A6"
        readonly property color border: "#b2bef7"
        readonly property color muted: "#C8D0EE"
        readonly property string wallpaper: "wallpapers/antidote.png"
    }

    readonly property var neotoxin: QtObject {
        readonly property color background: "#1D2026"
        readonly property color foreground: "#CFD9C5"
        readonly property color accent1: "#C2F216"
        readonly property color accent2: "#3A4E29"
        readonly property color accent3: "#f0f556"
        readonly property color border: "#3b3f40"
        readonly property color muted: "#2d3133"
        readonly property string wallpaper: "wallpapers/neotoxin.png"
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

    readonly property int launcherWidth: 700
    readonly property int launcherHeight: 400

    readonly property string machine: "asus"
}
