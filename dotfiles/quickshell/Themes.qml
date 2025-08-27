pragma Singleton

import Quickshell
import QtQuick

Singleton {

    // background: arbitrary which looks best
    // foreground: text color so oposite of background
    // accent1: primary flashy color
    // accent2: same tint as accent1 but darker or lighter depending on background
    // accent3: secondary flashy color
    // border: rather light muted
    // muted: mix between background and foreground
    
    // megalinee is a legacy theme 
    readonly property var megalinee: QtObject {
        readonly property color background: "#0a000a"
        readonly property color foreground: "#ECEFF4"
        readonly property color accent1: "#F970CD"
        readonly property color accent2: "#381254"
        readonly property color accent3: "#20FF4F"
        readonly property color border: "#4C566A"
        readonly property color muted: "#3b033b"
        readonly property string wallpaper: "wallpapers/megalinee.png"
        readonly property string fontFamily: "JetBrainsMono NF"
    }

    readonly property var antidote: QtObject {
        readonly property color background: "#DCE2F2"
        readonly property color foreground: "#808FD6"
        readonly property color accent1: "#9B49A6"
        readonly property color accent2: "#D4A7E4"
        readonly property color accent3: "#E057F2"
        readonly property color border: "#b2bef7"
        readonly property color muted: "#C8D0EE"
        readonly property string wallpaper: "wallpapers/antidote.png"
        readonly property string fontFamily: "JetBrainsMono NF"
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
        readonly property string fontFamily: "JetBrainsMono NF"
    }

    readonly property var aquaEterna: QtObject {
        readonly property color background: "#6581A6"
        readonly property color foreground: "#BFBABA"
        readonly property color accent1: "#364573"
        readonly property color accent2: "#8AAED1"
        readonly property color accent3: "#5F6587"
        readonly property color border: "#b2bef7"
        readonly property color muted: "#929db0"
        readonly property string wallpaper: "./wallpapers/aqua-eterna.png"
        readonly property string fontFamily: "JetBrainsMono NF"
    }

    readonly property var commandPrompt: QtObject {
        readonly property color background: "#5E50C4"
        readonly property color foreground: "#F2F2F2"
        readonly property color accent1: "#68CEF6"
        readonly property color accent2: "#A67EFC"
        readonly property color accent3: "#5F7ED9"
        readonly property color border: "#b2bef7"
        readonly property color muted: "#8f85d3"
        readonly property string wallpaper: "./wallpapers/commandpropmpt.png"
        readonly property string fontFamily: "JetBrainsMono NF"
    }

    readonly property var submerged: QtObject {
        readonly property color background: "#00030D"
        readonly property color foreground: "#DAFFFF"
        readonly property color accent1: "#8BD45F"
        readonly property color accent2: "#B8F2B6"
        readonly property color accent3: "#70C8FE"
        readonly property color border: "#78838A"
        readonly property color muted: "#6e8287"
        readonly property string wallpaper: "./wallpapers/submerged.png"
        readonly property string fontFamily: "JetBrainsMono NF"
    }

    readonly property var takaZero: QtObject {
        readonly property color background: "#04090D"
        readonly property color foreground: "#A8B6BF"
        readonly property color accent1: "#D90404"
        readonly property color accent2: "#730710"
        readonly property color accent3: "#39576E"
        readonly property color border: "#2C3342"
        readonly property color muted: "#182736"
        readonly property string wallpaper: "./wallpapers/taka-zero.png"
        readonly property string fontFamily: "JetBrainsMono NF"
    }

    readonly property var xXd1mensionXx: QtObject {
        readonly property color background: "#4183D9"
        readonly property color foreground: "#E4EAF2"
        readonly property color accent1: "#E260D4"
        readonly property color accent2: "#9466D4"
        readonly property color accent3: "#DDBC69"
        readonly property color border: "#BDDAFF"
        readonly property color muted: "#91b6e6"
        readonly property string wallpaper: "./wallpapers/xXd1mensionXx.jpg"
        readonly property string fontFamily: "JetBrainsMono NF"
    }

    readonly property var coplandOS: QtObject {
        readonly property color background: "#020659"
        readonly property color foreground: "#7EBCF2"
        readonly property color accent1: "#034C8C"
        readonly property color accent2: "#04275C"
        readonly property color accent3: "#0A266B"
        readonly property color border: "#7EA2E0"
        readonly property color muted: "#4c73b5"
        readonly property string wallpaper: "./wallpapers/copland-os.png"
        readonly property string fontFamily: "JetBrainsMono NF"
    }

    readonly property var shootingStar: QtObject {
        readonly property color background: "#0D0D0D"
        readonly property color foreground: "#F2F2F2"
        readonly property color accent1: "#F2E307"
        readonly property color accent2: "#F2A007"
        readonly property color accent3: "#F079F2"
        readonly property color border: "#707070"
        readonly property color muted: "#464646"
        readonly property string wallpaper: "./wallpapers/shooting-star.jpg"
        readonly property string fontFamily: "JetBrainsMono NF"
    }

    readonly property var astralinsang: QtObject {
        readonly property color background: "#0D0D0D"
        readonly property color foreground: "#D5DCF2"
        readonly property color accent1: "#2D356B"
        readonly property color accent2: "#8298D9"
        readonly property color accent3: "#575E8C"
        readonly property color border: "#b2bef7"
        readonly property color muted: "#929db0"
        readonly property string wallpaper: "./wallpapers/astralinsang.jpg"
        readonly property string fontFamily: "JetBrainsMono NF"
    }
}
