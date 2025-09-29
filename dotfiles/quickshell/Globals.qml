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

    readonly property var theme: Themes.takaZero

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
