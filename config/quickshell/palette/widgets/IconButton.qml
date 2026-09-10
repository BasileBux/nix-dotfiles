import QtQuick
import QtQuick.Controls
import "../.."
import "../../widgets" as Widgets

// Square icon affordance, pill-shaped so it obeys the "pills are not concentric"
// exemption. Every hand-rolled TintIcon-plus-MouseArea site in the palette is one
// of these, so hover and press feel the same everywhere.
Item {
    id: root

    // Accent fill with dark glyph: the "this toggle is on" state (DND, audio).
    property bool active: false
    // Destructive affordance: forget a device, close a notification.
    property bool danger: false
    property string icon
    property int iconSize: 22
    property int size: 36
    property string tooltip: ""

    signal clicked

    implicitHeight: size
    implicitWidth: size
    opacity: enabled ? 1 : 0.35

    Rectangle {
        id: background

        anchors.fill: parent
        border.color: root.hovered && !root.active && !root.danger ? Globals.surfaceHoverBorder : "transparent"
        border.width: 1
        color: {
            if (root.active)
                return Globals.accent;
            if (root.danger && root.hovered)
                return Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.12);
            if (ma.pressed)
                return Globals.surfacePressed;
            if (root.hovered)
                return Globals.surfaceHover;
            return "transparent";
        }
        radius: height / 2
        scale: ma.pressed ? 0.94 : 1

        Behavior on color {
            ColorAnimation {
                duration: Globals.motionHover
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: ma.pressed ? Globals.motionPress : Globals.motionSettle
                easing.type: Easing.OutCubic
            }
        }
    }
    Widgets.TintIcon {
        anchors.centerIn: parent
        color: {
            if (root.active)
                return Globals.accentContent;
            if (root.danger)
                return root.hovered ? Globals.colors.danger : Globals.theme.foreground;
            return Globals.theme.foreground;
        }
        height: iconSize
        name: root.icon
        width: iconSize
    }
    MouseArea {
        id: ma

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: root.clicked()
    }
    ToolTip.visible: hovered && tooltip !== ""
    ToolTip.text: tooltip
    ToolTip.delay: 500

    readonly property bool hovered: ma.containsMouse
}
