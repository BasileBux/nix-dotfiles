import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."
import "../modules" as Modules

BarPart {
	id: root
	property var moduleSizes: [ 30, 60, 60, 35, 40, 60 ]

	property var batteryPopup: batteryContent.popupRef
	property var clockPopup: clockContent.popupRef
	property var lockPopup: lockContent.popupRef
	property var wifiPopup: wifiContent.popupRef
	property var bluetoothPopup: bluetoothContent.popupRef
	property var audioPopup: audioContent.popupRef

	ColumnLayout {
		id: layout
		spacing: Globals.spacing
		anchors {
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		Item {
			id: audioModule
			Layout.fillWidth: true
			implicitHeight: moduleSizes[5]
			Modules.Audio {
				id: audioContent
				popupYpos: bar.height - (7 * Globals.spacing + moduleSizes[0] + moduleSizes[1] + moduleSizes[2] + moduleSizes[3] + moduleSizes[4] + (moduleSizes[5] / 2) + (50/2) + Globals.radius)
			}
		}
		Item {
			id: bluetoothModule
			Layout.fillWidth: true
			implicitHeight: moduleSizes[4]
			Modules.Bluetooth {
				id: bluetoothContent
				popupYpos: bar.height - (6 * Globals.spacing + moduleSizes[0] + moduleSizes[1] + moduleSizes[2] + moduleSizes[3] + (moduleSizes[4] / 2) + (400/2) + Globals.radius)
			}
		}
		Item {
			id: wifiModule
			Layout.fillWidth: true
			implicitHeight: moduleSizes[3]
			Modules.Network {
				id: wifiContent
				popupYpos: bar.height - (5 * Globals.spacing + moduleSizes[0] + moduleSizes[1] + moduleSizes[2] + (moduleSizes[3] / 2) + (360/2) + Globals.radius)
			}
		}
		Item {
			id: batteryModule
			Layout.fillWidth: true
			implicitHeight: moduleSizes[2]
			Modules.Battery{
				id: batteryContent
				popupYpos: bar.height - (4 * Globals.spacing + moduleSizes[0] + moduleSizes[1] + (moduleSizes[2] / 2) + (190/2) + Globals.radius)
			}
		}
		Item {
			id: clockModule
			Layout.fillWidth: true
			implicitHeight: moduleSizes[1]
			Modules.Clock {
				id: clockContent
				popupYpos: bar.height - (3 * Globals.spacing + moduleSizes[0] + (moduleSizes[1] / 2) + (60/2) + Globals.radius)
			}
		}
		Item {
			id: lockModule
			Layout.fillWidth: true
			implicitHeight: moduleSizes[0]
			Modules.Lock {
				id: lockContent
			}
		}
	}
}
