import QtQuick
import "../.."

// The one elevation primitive. Every card, tile, view container and well in the
// palette is a Surface, so "what a panel looks like" has exactly one definition.
//
// level 1 — card: 4% white, 10% hairline, a soft contact shadow.
// level 2 — raised: hover/press/popover/selected. Brighter fill and hairline.
// level 3 — well: 22% black, no shadow. Reads as recessed (fields, tracks, wells).
//
// Children land in the padded content area, which is also what keeps the inner
// radius concentric: inner = cornerRadius - padding.
Item {
    id: root

    // Colour override: the opaque tone ramp, a destructive hover tint.
    property color fill: "transparent"
    // Edge-to-edge content: the one case where padding does not apply.
    property bool flush: false
    readonly property bool hovered: ma.containsMouse
    // Interactive surfaces own hover/press and expose clicked().
    property bool interactive: false
    property int level: 1
    // A card that sits inside another Surface: the glass is one step further
    // away, so its fill steps up to stay visible.
    property bool nested: false
    property int padding: Globals.space2
    // Pills are exempt from the concentric rule and must never take a fixed radius.
    property bool pill: false
    property int cornerRadius: Globals.cardRadius
    // Escape hatch for the drop-target overlay, which needs a 2 px accent ring.
    property color strokeColor: root.level === 3 ? Globals.wellBorder : root.interactive && root.hovered ? Globals.surfaceHoverBorder : Globals.surfaceBorder
    property int strokeWidth: 1
    readonly property bool pressed: interactive && ma.pressed
    readonly property color hoverFill: root.nested ? Qt.rgba(1, 1, 1, 0.13) : Globals.surfaceHover
    readonly property color restingFill: root.nested ? Qt.rgba(1, 1, 1, 0.06) : Globals.surface
    readonly property int surfaceRadius: root.pill ? height / 2 : root.cornerRadius

    default property alias content: contentArea.data

    signal clicked

    scale: root.pressed ? 0.985 : 1

    Behavior on scale {
        NumberAnimation {
            duration: root.pressed ? Globals.motionPress : Globals.motionSettle
            easing.type: Easing.OutCubic
        }
    }

    // Contact shadow, stacked veils. A MultiEffect used as `layer.effect` is
    // clipped to the item's own bounds in this Qt version, so the shadow has to
    // be painted by siblings. Three steps is enough to read as soft at 1x.
    Rectangle {
        anchors.top: background.top
        anchors.topMargin: Globals.space2 - 2
        color: Qt.rgba(0, 0, 0, 0.06)
        height: background.height
        radius: background.radius + 4
        visible: root.level !== 3
        width: background.width + 14
        x: background.x - 7
    }
    Rectangle {
        anchors.top: background.top
        anchors.topMargin: Globals.space1 - 1
        color: Qt.rgba(0, 0, 0, 0.10)
        height: background.height
        radius: background.radius + 2
        visible: root.level !== 3
        width: background.width + 6
        x: background.x - 3
    }
    Rectangle {
        id: nearShadow

        anchors.top: background.top
        anchors.topMargin: Globals.space1 - 3
        color: Qt.rgba(0, 0, 0, 0.18)
        height: background.height
        radius: background.radius + 1
        visible: root.level !== 3
        width: background.width + 2
        x: background.x - 1
    }
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.12)
        radius: root.surfaceRadius
        visible: root.level !== 3
    }
    Rectangle {
        id: background

        anchors.fill: parent
        border.color: root.strokeColor
        border.width: root.strokeWidth
        color: {
            if (root.fill.a > 0)
                return root.fill;
            if (root.level === 3)
                return Globals.well;
            if (root.pressed)
                return Globals.surfacePressed;
            if (root.interactive && root.hovered)
                return root.hoverFill;
            return root.restingFill;
        }
        radius: root.surfaceRadius

        Behavior on border.color {
            ColorAnimation {
                duration: Globals.motionHover
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: Globals.motionHover
                easing.type: Easing.OutCubic
            }
        }
    }
    // Declared before the content area, so embedded controls get events first.
    MouseArea {
        id: ma

        anchors.fill: parent
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.interactive
        hoverEnabled: true

        onClicked: root.clicked()
    }
    // Children declared inside a Surface land here, inset by `padding`.
    Item {
        id: contentArea

        anchors.fill: parent
        anchors.bottomMargin: root.flush ? 0 : root.padding
        anchors.leftMargin: root.flush ? 0 : root.padding
        anchors.rightMargin: root.flush ? 0 : root.padding
        anchors.topMargin: root.flush ? 0 : root.padding
    }
}
