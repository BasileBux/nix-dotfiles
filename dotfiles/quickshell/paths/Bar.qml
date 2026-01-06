import Quickshell
import QtQuick
import QtQuick.Shapes
import ".."

Shape {
    id: barShape
    anchors.fill: parent

    ShapePath {
        id: barPath
        strokeWidth: 0
        strokeColor: "transparent"
        fillColor: Globals.theme.background
        startX: -(root.padding)
        startY: 0

        PathArc {
            relativeX: root.radius
            relativeY: root.radius
            radiusX: root.radius
            radiusY: root.radius
            direction: PathArc.Clockwise
        }

        PathLine {
            relativeX: 0
            relativeY: root.height - (root.radius * 2)
        }

        PathArc {
            relativeX: -(root.radius)
            relativeY: root.radius
            radiusX: root.radius
            radiusY: root.radius
            direction: PathArc.Clockwise
        }

        PathLine {
            relativeX: root.width + root.padding
            relativeY: 0
        }

        PathLine {
            relativeX: 0
            relativeY: -(root.height)
        }
    }
}
