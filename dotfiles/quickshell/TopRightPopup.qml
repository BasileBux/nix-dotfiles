import Quickshell
import QtQuick
import QtQuick.Shapes
import "paths" as Paths

// Same exact API as Popup.qml

PopupWindow {
    id: popup
    // Reference to the parent component that manages the popup
    required property var ref
    // ref must implement the following properties:
    // - collapseAllBut: function(name) { ... }

    required property int popupWidth
    required property int popupHeight
    required property int yPos
    required property string name
    property bool debug: false
    property color popupColor: Globals.theme.background

    default property alias content: contentContainer.data

    property bool shown: debug ? true : false
    visible: debug ? true : false
    implicitWidth: popupWidth
    implicitHeight: popupHeight + Globals.radius * 2

    anchor {
        window: ref
        gravity: Edges.Bottom | Edges.Left
        rect.x: Globals.radius / 2
        rect.y: yPos
        // Very important but allows to have popups outside the screen
        adjustment: PopupAdjustment.None
    }
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
        implicitHeight: popup.popupHeight + Globals.radius * 2

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

        Paths.TopRightPopup {
            id: popupShape
            popupWidth: popup.popupWidth
            popupHeight: popup.popupHeight
            popupColor: popup.popupColor
        }

        Item {
            id: contentContainer
            anchors {
                fill: parent
            }
            anchors.leftMargin: Globals.radius
            anchors.topMargin: Globals.radius / 2
            anchors.bottomMargin: Globals.radius
        }
    }
}
