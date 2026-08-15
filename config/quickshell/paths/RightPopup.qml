import Quickshell
import QtQuick
import QtQuick.Shapes
import ".."

Shape {
    id: popupShape

    required property int popupWidth
    required property int popupHeight
    required property color popupColor

    width: popupWidth
    height: popupHeight + Globals.radius * 2

    x: 0

    ShapePath {
        id: popupPath
        strokeWidth: 0
        strokeColor: "transparent"
        fillColor: popupColor

        startX: popupShape.width
        startY: 0

        PathArc {
            x: popupShape.width - Globals.radius
            y: Globals.radius
            radiusX: Globals.radius
            radiusY: Globals.radius
        }

        PathLine {
            x: Globals.radius
            y: Globals.radius
        }
        PathArc {
            x: 0
            y: Globals.radius * 2
            radiusX: Globals.radius
            radiusY: Globals.radius
            direction: PathArc.Counterclockwise
        }
        PathLine {
            x: 0
            y: popupShape.height - Globals.radius * 2
        }
        PathArc {
            x: Globals.radius
            y: popupShape.height - Globals.radius
            radiusX: Globals.radius
            radiusY: Globals.radius
            direction: PathArc.Counterclockwise
        }
        PathLine {
            x: popupShape.width - Globals.radius
            y: popupShape.height - Globals.radius
        }

        PathArc {
            x: popupShape.width
            y: popupShape.height
            radiusX: Globals.radius
            radiusY: Globals.radius
        }
    }
}
