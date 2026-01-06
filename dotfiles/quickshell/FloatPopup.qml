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

    anchor.rect.x: -width + ref.padding - ref.spacing
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
        id: spacer
        anchors.fill: parent
        Rectangle {
            id: wrapper
            color: popup.popupColor
            radius: ref.radius
            opacity: 1.0

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left: parent.left
                leftMargin: ref.padding
                topMargin: ref.radius + ref.padding
                bottomMargin: ref.radius + ref.padding
            }

            clip: true
            state: debug ? "visible" : "hidden"

            property int animationDuration: 50

            states: [
                State {
                    name: "hidden"
                    PropertyChanges {
                        wrapper.opacity: 0.0
                        popup.visible: false
                    }
                },
                State {
                    name: "visible"
                    PropertyChanges {
                        wrapper.opacity: 1.0
                        popup.visible: true
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        OpacityAnimator {
                            target: wrapper
                            duration: wrapper.animationDuration
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
                        OpacityAnimator {
                            target: wrapper
                            duration: wrapper.animationDuration
                        }
                    }
                }
            ]

            Item {
                id: contentContainer
                anchors {
                    fill: parent
                    margins: ref.padding
                }
                anchors.topMargin: ref.radius
                anchors.bottomMargin: ref.radius
            }
        }
    }
}
