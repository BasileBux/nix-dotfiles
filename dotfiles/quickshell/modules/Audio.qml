import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services
import ".."

Item {
	id: root
	anchors.fill: parent
	required property int popupYpos
	readonly property alias popupRef: popup

	ColumnLayout {
		anchors.fill: parent
		spacing: 0
		Button {
			id: audioIcon
			Layout.alignment: Qt.AlignHCenter
			background: Rectangle {
				color: "transparent"
			}
			icon.source: Services.Audio.muted ? "../icons/muted.svg" : "../icons/audio.svg"
			icon.width: parent.width * 0.5
			icon.height: parent.width * 0.5
			icon.color: Globals.theme.foreground
		}

		Text {
			id: volumeText
			Layout.alignment: Qt.AlignHCenter
			color: Globals.theme.foreground
			font.pixelSize: Globals.fonts.medium
			text: Services.Audio.volume === NaN ? "0%" : (Services.Audio.volume * 100).toFixed(0) + "%"
		}
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onClicked: {
			popup.toggle();
			bar.focusGrab.active = popup.shown;
		}
		onEntered: {
			audioIcon.icon.color = Globals.theme.accent2;
			volumeText.color = Globals.theme.accent2;
		}
		onExited: {
			audioIcon.icon.color = Globals.theme.foreground;
			volumeText.color = Globals.theme.foreground;
		}
	}

	Popup {
		id: popup
		ref: bar
		popupIndex: 5
		popupHeight: 50
		popupWidth: 240
		yPos: root.popupYpos
		AudioPopup {}
	}
}
