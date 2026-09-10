import Quickshell
import QtQuick

// Standalone test entry for LowBatteryOverlay — run it alongside your real
// shell without duplicating wallpaper/notifications:
//
//   Fixed level (overrides the real battery):
//     BATTERY_TEST_PCT=12 qs -p vignette-test.qml
//
//   Demo ramp: cycles 20% -> 4% in 2% steps every 1.5s, then restarts:
//     BATTERY_TEST_DEMO=1 qs -p vignette-test.qml
//
//   Real battery behavior (only shows while discharging below 20%):
//     qs -p vignette-test.qml
ShellRoot {
    LowBatteryOverlay {
        id: vignette

        property real demoPct: 20
        // Fixed level wins; otherwise demo ramp if BATTERY_TEST_DEMO is set;
        // otherwise fall back to the overlay's own env/real-battery default.
        testPct: {
            var v = parseFloat(Quickshell.env("BATTERY_TEST_PCT"));
            if (!isNaN(v))
                return Math.min(100, Math.max(0, v));
            return Quickshell.env("BATTERY_TEST_DEMO") ? demoPct : -1;
        }
    }

    Timer {
        interval: 1500
        repeat: true
        running: Quickshell.env("BATTERY_TEST_DEMO") != null && Quickshell.env("BATTERY_TEST_DEMO") !== ""

        onTriggered: {
            vignette.demoPct = vignette.demoPct <= 4 ? 20 : vignette.demoPct - 2;
            console.log("demo battery:", vignette.demoPct + "%");
        }
    }
}
