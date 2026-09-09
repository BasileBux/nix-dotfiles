import QtQuick
import ".."

Rectangle {
    id: root

    property string text: ""
    // accent1 pill when true, muted pill when false
    property bool highlighted: false
    signal clicked()

    implicitWidth: label.implicitWidth + Globals.spacing * 4
    implicitHeight: 28
    radius: height / 2
    color: {
        if (!enabled) return Globals.theme.muted;
        if (highlighted) return Globals.theme.accent1;
        return ma.containsMouse ? Globals.theme.border : Globals.theme.muted;
    }
    opacity: enabled ? 1.0 : 0.45

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        id: label
        anchors.centerIn: parent
        color: root.highlighted && root.enabled ? Globals.theme.background : Globals.theme.foreground
        font.pixelSize: Globals.fonts.small
        font.family: Globals.theme.fontFamily
        font.bold: root.highlighted
        text: root.text
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
