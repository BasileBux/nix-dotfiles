import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import ".."

Rectangle {
	id: root
	required property LockContext context

	color: Globals.theme.background

	// Test button
	// Button {
	// 	text: "Its not working, let me out"
	// 	onClicked: context.unlocked();
	// }

	Image {
		id: backgroundImage
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop
		source: "../" + Globals.theme.wallpaper
		opacity: 0.3
	}

	Label {
		id: clock
		property var date: new Date()

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.verticalCenter
			topMargin: -80
		}

		renderType: Text.NativeRendering
		font.pointSize: 80
		font.family: Globals.theme.fontFamily
		color: Globals.theme.foreground

		Timer {
			running: true
			repeat: true
			interval: 1000

			onTriggered: clock.date = new Date();
		}

		text: {
			const hours = this.date.getHours().toString().padStart(2, '0');
			const minutes = this.date.getMinutes().toString().padStart(2, '0');
			const seconds = this.date.getSeconds().toString().padStart(2, '0');
			return `${hours}:${minutes}:${seconds}`;
		}
	}

	ColumnLayout {
		// Make the password entry invisible except on the active monitor.
		visible: Window.active

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.verticalCenter
			topMargin: 80
		}

		RowLayout {
			TextField {
				id: passwordBox

				implicitWidth: 300
				implicitHeight: 50
				padding: 10

				focus: true
				enabled: !root.context.unlockInProgress
				echoMode: TextInput.Password
				inputMethodHints: Qt.ImhSensitiveData

				horizontalAlignment: TextInput.AlignHCenter
				font.pixelSize: Globals.fonts.large
				color: Globals.theme.foreground

				background: Rectangle {
					color: Globals.theme.accent1
					border.color: "transparent"
					radius: 25
					border.width: 0
				}

				// Update the text in the context when the text in the box changes.
				onTextChanged: root.context.currentText = this.text;

				// Try to unlock when enter is pressed.
				onAccepted: root.context.tryUnlock();

				// Update the text in the box to match the text in the context.
				// This makes sure multiple monitors have the same text.
				Connections {
					target: root.context

					function onCurrentTextChanged() {
						passwordBox.text = root.context.currentText;
					}
				}
			}
		}

		Label {
			color: Globals.theme.accent3
			visible: root.context.showFailure
			font.pixelSize: Globals.fonts.medium
			text: "Incorrect password"
		}
	}
}
