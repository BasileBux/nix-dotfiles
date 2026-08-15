import Quickshell
import QtQuick
import QtQuick.Layouts
import ".."
import "../modules" as Modules

BarPart {

    ColumnLayout {
        id: layout
        spacing: Globals.spacing
        anchors.fill: parent
        uniformCellSizes: false
        Item {
            id: workspacesModule
            Layout.fillWidth: true
            implicitHeight: 60
            Modules.Workspaces {
                id: workspacesContent
            }
        }
    }
}
