import Quickshell
import QtQuick
import QtQuick.Shapes
import "paths" as Paths

PopupWindow {
    id: popup
    // Reference to the parent component that manages the popup
    required property var ref
    // ref must implement the following properties:
    // - collapseAllBut: function(name) { ... }

    required property int popupWidth
    required property int popupHeight
    property int yPos: 0
    required property string name
    property var moduleRef: null
    property bool debug: false
    property color popupColor: Globals.theme.background
    // true  -> anchored to the bar's top-right, uses Paths.TopRightPopup shape
    // false -> anchored to the bar's left side, uses Paths.RightPopup shape
    property bool topRight: false

    default property alias content: contentContainer.data

    property bool shown: debug ? true : false
    visible: debug ? true : false
    implicitWidth: popupWidth
    implicitHeight: popupHeight + Globals.radius * 2

    anchor {
        window: ref
        rect.x: topRight ? Globals.radius / 2 : (-width + Globals.radius - Globals.padding)
        rect.y: yPos
    }

    // Only apply top-right-specific anchor flags in that mode;
    // otherwise the anchor reverts to its default behavior.
    Binding {
        target: popup.anchor
        property: "gravity"
        value: Edges.Bottom | Edges.Left
        when: topRight
    }

    Binding {
        target: popup.anchor
        property: "adjustment"
        value: PopupAdjustment.None
        when: topRight
    }

    color: "transparent"

    property var collapse: function () {
        wrapper.state = "hidden";
        shown = false;
    }

    function updateYpos() {
        if (moduleRef) {
            var center = moduleRef.mapToItem(null, 0, moduleRef.height / 2);
            // Center the popup content vertically on the module. The popup window is
            // taller than the content by the corner radius, so offset by that amount.
            yPos = center.y - popupHeight / 2 - Globals.radius;
        }
    }

    property var toggle: function () {
        updateYpos();
        wrapper.state === "hidden" ? wrapper.state = "visible" : wrapper.state = "hidden";
        shown = wrapper.state === "visible";
        ref.collapseAllBut(name);
    }

    property var show: function () {
        updateYpos();
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

        Paths.RightPopup {
            id: rightPopupShape
            visible: !topRight
            popupWidth: popup.popupWidth
            popupHeight: popup.popupHeight
            popupColor: popup.popupColor
        }

        Paths.TopRightPopup {
            id: topRightPopupShape
            visible: topRight
            popupWidth: popup.popupWidth
            popupHeight: popup.popupHeight
            popupColor: popup.popupColor
        }

        Item {
            id: contentContainer
            anchors {
                fill: parent
                margins: topRight ? 0 : Globals.padding
            }
            anchors.leftMargin: topRight ? Globals.radius : Globals.padding
            anchors.topMargin: topRight ? Globals.radius / 2 : Globals.radius * 2
            anchors.bottomMargin: topRight ? Globals.radius : Globals.radius * 2
            anchors.rightMargin: topRight ? 0 : Globals.padding
        }
    }
}
