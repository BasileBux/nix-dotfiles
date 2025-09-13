import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
	id: item
	required property var iconSource
	required property real scaleFactor
	required property color iconColor
	required property color hoverColor
	required property var exec

	property real animActive: 0
	Behavior on animActive { NumberAnimation { duration: 150 } }

	Layout.alignment: Qt.AlignHCenter
	Layout.fillWidth: true
	Layout.fillHeight: true
	Button {
		id: button
		anchors.fill: parent
		background: Rectangle {
			color: "transparent"
		}
		icon.source: iconSource
		icon.width: (item.width * scaleFactor) + (animActive * 10)
		icon.height: (item.width * scaleFactor) + (animActive * 10)
		icon.color: iconColor
	}
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onClicked: {
			item.exec();
		}
		onEntered: {
			button.icon.color = hoverColor;
			animActive = 1;
		}
		onExited: {
			button.icon.color = iconColor;
			animActive = 0;
		}
	}
}
