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
		startX: root.padding + root.radius
		startY: root.padding

		PathArc {
			relativeX: -(root.radius)
			relativeY: root.radius
			radiusX: root.radius
			radiusY: root.radius
			direction: PathArc.Counterclockwise
		}

		PathLine {
			relativeX: 0
			relativeY: root.height - (root.padding * 2 + root.radius * 2)
		}

		PathArc {
			relativeX: root.radius
			relativeY: root.radius
			radiusX: root.radius
			radiusY: root.radius
			direction: PathArc.Counterclockwise
		}

		PathLine {
			relativeX: root.width - (root.padding * 2 + root.radius * 2)
			relativeY: 0
		}

		PathArc {
			relativeX: root.radius
			relativeY: -(root.radius)
			radiusX: root.radius
			radiusY: root.radius
			direction: PathArc.Counterclockwise
		}

		PathLine {
			relativeX: 0
			relativeY: -(root.height - (root.padding * 2 + root.radius * 2))
		}

		PathArc {
			relativeX: -(root.radius)
			relativeY: -(root.radius)
			radiusX: root.radius
			radiusY: root.radius
			direction: PathArc.Counterclockwise
		}
	}
}
