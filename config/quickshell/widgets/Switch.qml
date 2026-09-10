import Quickshell
import QtQuick
import ".."

// Off remains a visible control, not a dark well or a disabled state.
Rectangle {
    id: toggle

    property int knobInset: 2
    property bool silent: true
    required property var toggleFunction
    required property bool toggleState

    implicitHeight: 24
    implicitWidth: 44
    radius: height / 2

    opacity: enabled ? 1 : 0.45
    border.color: ma.containsMouse ? Qt.lighter(Globals.controlBorder, 1.3) : toggleState ? Globals.accent : Globals.controlBorder
    border.width: 1
    color: toggleState ? Globals.accent : ma.containsMouse ? Qt.lighter(Globals.controlTrack, 1.15) : Globals.controlTrack

    Behavior on color {
        ColorAnimation {
            duration: Globals.motionSettle
        }
    }

    Component.onCompleted: {
        silent = false;
    }
    onToggleStateChanged: {
        if (!silent)
            Globals.playSound(toggleState ? Globals.sounds.toggleOn : Globals.sounds.toggleOff);
    }

    Rectangle {
        id: knob

        anchors.verticalCenter: parent.verticalCenter
        color: toggle.toggleState ? Globals.accentContent : Globals.theme.foreground
        height: parent.height - toggle.knobInset * 2
        radius: height / 2
        width: height
        x: toggle.toggleState ? toggle.width - width - toggle.knobInset : toggle.knobInset

        Behavior on x {
            NumberAnimation {
                duration: Globals.motionSettle
                easing.type: Easing.OutCubic
            }
        }
    }
    MouseArea {
        id: ma

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: toggle.toggleFunction()
    }
}
