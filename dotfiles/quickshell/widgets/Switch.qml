import Quickshell
import QtQuick
import ".."

Rectangle {
    id: toggle
    property int widgetWidth: 60
    property int widgetHeight: 30

    required property var toggleFunction
    required property bool toggleState

    property color bgColorOn: Globals.theme.accent3
    property color bgColorOff: Globals.theme.muted
    property color selectorColor: Globals.theme.border

    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    radius: width / 2

    MouseArea {
        anchors.fill: parent
        onClicked: {
            toggle.toggleFunction();
        }
    }

    Rectangle {
        id: selector
        color: toggle.selectorColor
        implicitWidth: parent.height
        implicitHeight: parent.height
        radius: Math.ceil(parent.height / 2)
    }
    states: [
        State {
            name: "on"
            when: toggle.toggleState
            PropertyChanges {
                selector.x: toggle.width - selector.width + 1
                toggle.color: bgColorOn
            }
        },
        State {
            name: "off"
            when: !toggle.toggleState
            PropertyChanges {
                selector.x: 0
                toggle.color: bgColorOff
            }
        }
    ]
    transitions: Transition {
        NumberAnimation {
            target: selector
            property: "x"
            duration: 80
        }
    }
}
