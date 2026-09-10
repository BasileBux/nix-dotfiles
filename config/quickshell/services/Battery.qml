pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

// Low-battery watchdog. Fires one notification per threshold (30/20/10%)
// per discharge cycle by spawning notify-send, which lands back on this
// shell's own NotificationServer and pops up as a normal toast.
Singleton {
    id: root

    // How far above the highest threshold the battery must climb before the
    // thresholds re-arm (covers charging, battery swaps, readjusted reports).
    // Derived from the threshold list, NOT a fixed value: a fixed 40% would
    // swallow any threshold set above 40% (e.g. when testing with 76%).
    readonly property real rechargeHysteresisMargin: 10
    // UPower reports 0..1
    readonly property real pct: UPower.displayDevice.percentage * 100
    // True only while the battery is actually draining (used by the
    // low-battery vignette so charging/AC hides it again).
    readonly property bool discharging: UPower.displayDevice.state == UPowerDeviceState.Discharging

    property var _fired: ({})

    function check() {
        var state = UPower.displayDevice.state;
        // UPower briefly reports Unknown/0% while connecting; firing here would
        // spam every threshold at (fake) 0% on each shell start.
        if (state == UPowerDeviceState.Unknown)
            return;
        var thresholds = [30, 20, 10];
        var pct = Math.round(root.pct);
        var rearmAt = thresholds[0] + root.rechargeHysteresisMargin;
        if (state == UPowerDeviceState.Charging || state == UPowerDeviceState.FullyCharged || pct >= rearmAt) {
            if (Object.keys(root._fired).length > 0)
                root._fired = {};
            return;
        }
        for (var i = 0; i < thresholds.length; i++) {
            var t = thresholds[i];
            if (!root._fired[t] && pct <= t) {
                root._fired[t] = true;
                root.notify(t);
            }
        }
    }

    function notify(threshold) {
        var critical = threshold <= 10;
        var summary = critical ? "Battery critical" : threshold <= 20 ? "Battery very low" : "Battery low";
        var body = "Battery is at " + Math.round(root.pct) + "%";
        var tte = UPower.displayDevice.timeToEmpty;
        if (!critical && tte > 0) {
            var m = Math.round(tte / 60);
            if (m >= 60)
                body += " · about " + Math.floor(m / 60) + "h " + (m % 60) + "m left";
            else
                body += " · about " + m + "m left";
        }
        // NOTE: must be a plain argv list — quickshell 0.3.1 cannot convert a
        // JS object ({command: ...}) to ProcessContext and silently drops it.
        // Icon: pass the shell's own SVG as a file:// URL — notify-send copies
        // it verbatim into the image-path hint, and quickshell uses file://
        // hints directly as Image.source. Theme icon names (e.g.
        // battery-level-30-symbolic) resolve via QIcon::fromTheme and render
        // as a missing-texture checkerboard because no installed theme has
        // battery icons. Use the white variant: the toast background is the
        // dark theme background, and battery.svg is black-on-transparent.
        Quickshell.execDetached([
            "notify-send",
            "--app-name=Battery",
            "--icon=" + Qt.resolvedUrl("../icons/battery-notification.svg"),
            "--urgency=" + (critical ? "critical" : "normal"),
            "--expire-time=" + (critical ? 0 : 10000),
            summary,
            body
        ]);
    }

    Component.onCompleted: root.check()
    onPctChanged: root.check()

    Timer {
        interval: 30000
        repeat: true
        running: true

        onTriggered: root.check()
    }
}
