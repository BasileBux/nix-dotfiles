import Quickshell
import Quickshell.Wayland
import QtQuick
import "services" as Services

// COD-style "low health" vignette for low battery: a fullscreen, click-through
// red vignette that appears at `triggerAt`% while discharging and ramps up to
// full strength at `maxAt`%, with a slow heartbeat pulse.
//
// Implemented as four linear-gradient strips (top/bottom/left/right) instead
// of a radial gradient: Qt 6.11's ShapePath.RadialGradient misapplies its
// centerX/centerY/centerRadius on this setup (uniform wash instead of a
// vignette), while Rectangle+Gradient is rock solid. The strips overlap at
// the corners, which naturally gives the stronger corner glow COD has.
//
// `step` quantizes the battery percentage before the intensity is computed:
// 1 = smooth ramp per percent, 5 = one step every 5%, etc.
PanelWindow {
    id: root

    readonly property real triggerAt: 20
    readonly property real maxAt: 5
    readonly property int step: 1
    readonly property int fadeMs: 500

	// Fraction of the screen each strip reaches inward. The falloff within a
    // strip is eased so the glow hugs the edge (COD-like) instead of fading
    // linearly.
    readonly property real edgeReach: 0.10
    readonly property real maxOpacity: 0.35

    // Test hook: launch with BATTERY_TEST_PCT=<0-100> to force a fake battery
    // level and pretend it is discharging, e.g.
    //   BATTERY_TEST_PCT=12 qs -p vignette-test.qml
    // Unset or invalid = real battery. Can also be assigned directly (it is
    // not readonly) by a test config that animates it.
    property real testPct: {
        var v = parseFloat(Quickshell.env("BATTERY_TEST_PCT"));
        return isNaN(v) ? -1 : Math.min(100, Math.max(0, v));
    }

    // 0 when pct >= triggerAt, 1 when pct <= maxAt, linear in between.
    readonly property real intensity: {
        var pct = testPct >= 0 ? testPct : Services.Battery.pct;
        if (step > 1)
            pct = Math.floor(pct / step) * step;
        return Math.min(1, Math.max(0, (triggerAt - pct) / (triggerAt - maxAt)));
    }
    readonly property bool active: (testPct >= 0 || Services.Battery.discharging) && intensity > 0



    // Keep the window mapped briefly after deactivating so the fade-out can
    // play before the layer surface goes away.
    visible: active || fadeTimer.running

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    aboveWindows: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "shell:battery-vignette"

    // Empty region = no input anywhere: pure overlay, clicks pass through.
    mask: Region {}

    anchors {
        bottom: true
        left: true
        right: true
        top: true
    }

    Item {
        id: vignette

        anchors.fill: parent
        opacity: root.active ? root.intensity * root.maxOpacity * pulse.scale : 0

        Behavior on opacity {
            NumberAnimation {
                duration: root.fadeMs
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: parent.height * root.edgeReach
            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 1)
                }
                GradientStop {
                    position: 0.30
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.55)
                }
                GradientStop {
                    position: 0.65
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.18)
                }
                GradientStop {
                    position: 1.00
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0)
                }
            }
        }
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: parent.height * root.edgeReach
            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0)
                }
                GradientStop {
                    position: 0.35
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.18)
                }
                GradientStop {
                    position: 0.70
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.55)
                }
                GradientStop {
                    position: 1.00
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 1)
                }
            }
        }
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * root.edgeReach
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.00
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 1)
                }
                GradientStop {
                    position: 0.30
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.55)
                }
                GradientStop {
                    position: 0.65
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.18)
                }
                GradientStop {
                    position: 1.00
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0)
                }
            }
        }
        Rectangle {
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * root.edgeReach
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.00
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0)
                }
                GradientStop {
                    position: 0.35
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.18)
                }
                GradientStop {
                    position: 0.70
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.55)
                }
                GradientStop {
                    position: 1.00
                    color: Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 1)
                }
            }
        }
    }

    // Heartbeat pulse: eases down and back up while the vignette is showing.
    QtObject {
        id: pulse

        property real scale: 1
    }
    SequentialAnimation {
        loops: Animation.Infinite
        running: root.active
        alwaysRunToEnd: true

        NumberAnimation {
            duration: 900
            easing.type: Easing.InOutSine
            property: "scale"
            target: pulse
            to: 0.7
        }
        NumberAnimation {
            duration: 900
            easing.type: Easing.InOutSine
            property: "scale"
            target: pulse
            to: 1
        }
    }

    Timer {
        id: fadeTimer

        interval: root.fadeMs + 100
    }
    onActiveChanged: {
        if (!root.active)
            fadeTimer.restart();
    }
}
