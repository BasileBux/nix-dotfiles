import Quickshell
import Quickshell.Services.Polkit
import QtQuick
import "lock"
import "notification"
import "palette"
import "services" as Services

ShellRoot {
    id: shellRoot

    // Keep the low-battery watchdog alive for the whole session; singletons
    // are lazily instantiated on first access, so it needs one reference here.
    readonly property bool _batteryWatchdog: Services.Battery.pct >= 0

    Wallpaper {
    }
    Palette {
    }
    VolumeOsd {
    }
    LowBatteryOverlay {
    }
    Notification {
    }
    Lock {
        id: lock
    }
    PolkitAgent {
        id: polkitAgent
        // path defaults to /org/quickshell/Polkit
    }
    AuthDialog {
        id: authDialog

        agent: polkitAgent
    }
}
