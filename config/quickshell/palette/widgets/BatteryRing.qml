import QtQuick
import "../.."
import "../../widgets" as Widgets

// Charge level uses green/amber/red; the bolt independently identifies charging.
Item {
    id: root

    property bool charging: false
    property real level: 0 // 0..1
    readonly property color ringColor: level <= 0.15 ? Globals.colors.danger : level <= 0.30 ? Globals.colors.warning : Globals.colors.success
    property int thickness: 5
    onLevelChanged: ring.requestPaint()
    onRingColorChanged: ring.requestPaint()

    Canvas {
        id: ring

        anchors.fill: parent
        antialiasing: true

        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const lw = root.thickness;
            const c = width / 2;
            const r = c - lw / 2;
            ctx.lineWidth = lw;
            ctx.lineCap = "round";

            // Track
            ctx.beginPath();
            ctx.arc(c, c, r, 0, 2 * Math.PI);
            ctx.strokeStyle = Globals.surfaceHover;
            ctx.stroke();

            // Progress, clockwise from 12 o'clock
            if (root.level > 0.005) {
                ctx.beginPath();
                ctx.arc(c, c, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * Math.min(root.level, 1));
                ctx.strokeStyle = root.ringColor;
                ctx.stroke();
            }
        }
        onWidthChanged: requestPaint()
    }
    Widgets.TintIcon {
        anchors.centerIn: parent
        color: root.charging ? Globals.colors.success : Globals.theme.foreground
        height: width
        name: root.charging ? "bolt" : "computer"
        width: parent.width * 0.5
    }
}
