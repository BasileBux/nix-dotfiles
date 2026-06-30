import Quickshell
import QtQuick
import QtQuick.Shapes

PanelWindow {
    id: corners
    anchors {
        top: true
        left: true
        bottom: true
    }

    margins {
        right: 0
        left: 0
        bottom: 0
        top: 0
    }
    implicitWidth: Globals.radius
    aboveWindows: false
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    Shape {
        id: cornerShape
        anchors.fill: parent
        ShapePath {
            id: cornerPathTop
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: Globals.theme.background
            startX: Globals.radius
            startY: 0

            PathArc {
                x: 0
                y: Globals.radius
                radiusX: Globals.radius
                radiusY: Globals.radius
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: 0
                y: 0
            }
        }

        ShapePath {
            id: cornerPathBottom
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: Globals.theme.background
            startX: Globals.radius
            startY: corners.height

            PathArc {
                x: 0
                y: corners.height - Globals.radius
                radiusX: Globals.radius
                radiusY: Globals.radius
                direction: PathArc.Clockwise
            }
            PathLine {
                x: 0
                y: corners.height
            }
        }
    }
}
