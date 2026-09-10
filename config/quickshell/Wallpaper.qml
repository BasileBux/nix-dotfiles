import Quickshell
import QtQuick

PanelWindow {
    aboveWindows: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false

    anchors {
        bottom: true
        left: true
        right: true
        top: true
    }
    Image {
        anchors.fill: parent
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        source: Globals.theme.wallpaper
        // smooth: false
    }
}
