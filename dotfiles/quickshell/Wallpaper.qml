import Quickshell
import QtQuick

PanelWindow {
	color: "transparent"
	anchors {
		left: true
		right: true
		top: true
		bottom: true
	}
	aboveWindows: false
	focusable: false
	exclusionMode: ExclusionMode.Ignore

	Image {
		source: Globals.theme.wallpaper
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop
		cache: true
		asynchronous: true
		// smooth: false
	}
}
