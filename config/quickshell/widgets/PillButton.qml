import QtQuick
import ".."

// Pill action. Rest is the raised tonal step, highlight is the accent fill with
// dark content — the only place a solid accent is allowed to carry a label.
Rectangle {
    id: root

    // accent fill when true, tonal pill when false
    property bool highlighted: false
    // Destructive action: outline until armed, then a danger tint. Never accent.
    property bool danger: false
    property bool confirmed: false
    property string text

    signal clicked

    border.color: {
        if (root.danger)
            return Globals.colors.danger;
        return ma.containsMouse && !root.highlighted ? Globals.surfaceHoverBorder : "transparent";
    }
    border.width: 1
    color: {
        if (!root.enabled)
            return Globals.well;
        if (root.highlighted)
            return Globals.accent;
        if (root.confirmed)
            return Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.18);
        return ma.pressed ? Globals.surfacePressed : Globals.surfaceHover;
    }
    implicitHeight: 32
    implicitWidth: label.implicitWidth + Globals.space4
    radius: height / 2

    Behavior on color {
        ColorAnimation {
            duration: Globals.motionHover
            easing.type: Easing.OutCubic
        }
    }

    Text {
        id: label

        anchors.centerIn: parent
        color: {
            if (!root.enabled)
                return Globals.theme.muted;
            if (root.highlighted)
                return Globals.accentContent;
            if (root.danger)
                return Globals.colors.dangerText;
            return Globals.theme.foreground;
        }
        font.family: Globals.theme.fontFamily
        font.pixelSize: Globals.fonts.body
        font.weight: Font.Medium
        text: root.text
    }
    MouseArea {
        id: ma

        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        hoverEnabled: true

        onClicked: root.clicked()
    }
}
