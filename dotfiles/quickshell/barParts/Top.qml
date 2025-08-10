import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."
import "../modules" as Modules

BarPart {
	property var moduleSizes: [ 60 ]

	ColumnLayout {
		id: layout
		spacing: Globals.spacing
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
		}
		uniformCellSizes: false
		Item {
			id: workspacesModule
			Layout.fillWidth: true
			implicitHeight: moduleSizes[0]
			Modules.Workspaces {
				id: workspacesContent
				popupYpos: bar.height - (moduleSizes[0] / 2 + Globals.radius)
			}
		}
	}
}
