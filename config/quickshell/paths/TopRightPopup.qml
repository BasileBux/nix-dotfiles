import Quickshell
import QtQuick
import QtQuick.Shapes
import ".."

Shape {
    id: popupShape

    required property int popupWidth
    required property int popupHeight
    required property color popupColor

    width: popupWidth + Globals.radius * 2
    height: popupHeight + Globals.radius * 2

    x: 0
    y: 0

    ShapePath {
        id: popupPath
        strokeWidth: 0
        strokeColor: "transparent"
        fillColor: popupColor

        startX: 0
        startY: 0

        PathArc {
            x: Globals.radius
            y: Globals.radius
            radiusX: Globals.radius
            radiusY: Globals.radius
        }

        PathLine {
            x: Globals.radius
            y: popupShape.height - Globals.radius * 2
        }

        PathArc {
            x: Globals.radius * 2
            y: popupShape.height - Globals.radius
            radiusX: Globals.radius
            radiusY: Globals.radius
            direction: PathArc.Counterclockwise
        }

        PathLine {
            x: popupShape.width - Globals.radius * 3
            y: popupShape.height - Globals.radius
        }

        PathArc {
            x: popupShape.width - Globals.radius * 2
            y: popupShape.height
            radiusX: Globals.radius
            radiusY: Globals.radius
            direction: PathArc.Clockwise
        }

        PathLine {
            x: popupShape.width - Globals.radius * 2
            y: 0
        }
    }
}
