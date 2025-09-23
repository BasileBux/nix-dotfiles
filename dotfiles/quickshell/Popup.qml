import Quickshell
import QtQuick
import QtQuick.Shapes

PopupWindow {
    id: popup
    // Reference to the parent component that manages the popup
    required property var ref
    // ref must implement the following properties:
    // - padding: int
    // - radius: int
    // - spacing: int
    // - popupColor: color
    // - collapseAllBut: function(name) { ... }

    required property int popupWidth
    required property int popupHeight
    required property int yPos
    property bool debug: false
    property color popupColor: ref.popupColor
    required property string name

    default property alias content: contentContainer.data

    property bool shown: debug ? true : false
    visible: debug ? true : false
    anchor.window: ref
    implicitWidth: popupWidth
    implicitHeight: popupHeight + ref.radius * 2

    anchor.rect.x: -width + ref.padding + 2
    anchor.rect.y: yPos
    color: "transparent"

    property var collapse: function () {
        wrapper.state = "hidden";
        shown = false;
    }

    property var toggle: function () {
        wrapper.state === "hidden" ? wrapper.state = "visible" : wrapper.state = "hidden";
        shown = wrapper.state === "visible";
        ref.collapseAllBut(name);
    }

    property var show: function () {
        wrapper.state = "visible";
        shown = true;
        ref.collapseAllBut(name);
    }

    Item {
        id: wrapper

        anchors.right: parent.right

        implicitWidth: 0
        implicitHeight: popup.popupHeight + ref.radius * 2

        clip: true
        state: debug ? "visible" : "hidden"

        states: [
            State {
                name: "hidden"
                PropertyChanges {
                    wrapper.implicitWidth: 0
                    popup.visible: false
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    wrapper.implicitWidth: popup.popupWidth
                    popup.visible: true
                }
            }
        ]

        transitions: [
            Transition {
                from: "visible"
                to: "hidden"
                SequentialAnimation {
                    NumberAnimation {
                        property: "implicitWidth"
                        duration: 200
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.2, 0, 0, 1, 1, 1] // Standard deceleration curve
                    }
                    NumberAnimation {
                        target: popup
                        property: "visible"
                        duration: 0
                    }
                }
            },
            Transition {
                from: "hidden"
                to: "visible"
                SequentialAnimation {
                    NumberAnimation {
                        target: popup
                        property: "visible"
                        duration: 0
                    }
                    NumberAnimation {
                        property: "implicitWidth"
                        duration: 200
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.05, 0, 0.15, 1, 1, 1] // Emphasized curve for entrance
                    }
                }
            }
        ]

        Shape {
            id: popupShape

            width: popup.popupWidth
            height: popup.popupHeight + ref.radius * 2

            x: 0

            ShapePath {
                id: mainPopupPath
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: popup.popupColor

                startX: popupShape.width - 1 - ref.radius
                startY: ref.radius

                PathLine {
                    x: ref.radius
                    y: ref.radius
                }
                PathArc {
                    x: 0
                    y: ref.radius * 2
                    radiusX: ref.radius
                    radiusY: ref.radius
                    direction: PathArc.Counterclockwise
                }
                PathLine {
                    x: 0
                    y: popupShape.height - ref.radius * 2
                }
                PathArc {
                    x: ref.radius
                    y: popupShape.height - ref.radius
                    radiusX: ref.radius
                    radiusY: ref.radius
                    direction: PathArc.Counterclockwise
                }
                PathLine {
                    x: popupShape.width - 1 - ref.radius
                    y: popupShape.height - ref.radius
                }
            }

            ShapePath {
                id: transitionPath
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: popup.popupColor

                startX: popupShape.width - 1
                startY: 0

                PathArc {
                    x: popupShape.width - 1 - ref.radius
                    y: ref.radius
                    radiusX: ref.radius
                    radiusY: ref.radius
                }
                PathLine {
                    x: popupShape.width - 1 - ref.radius
                    y: popupShape.height - ref.radius
                }
                PathArc {
                    x: popupShape.width - 1
                    y: popupShape.height
                    radiusX: ref.radius
                    radiusY: ref.radius
                }
                PathLine {
                    x: popupShape.width - 1
                    y: 0
                }
            }
        }

        Item {
            id: contentContainer
            anchors {
                fill: parent
                margins: ref.padding
            }
            anchors.topMargin: ref.radius * 2
            anchors.bottomMargin: ref.radius * 2
        }
    }
}
