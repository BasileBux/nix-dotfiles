import Quickshell
import Quickshell.Services.Polkit
import QtQuick
import "launcher"
import "lock"
import "notification"

ShellRoot {
    id: shellRoot
    Wallpaper {}
    Bar {
        id: bar
        lock: lock
        notificationPanel: notification.notificationPanel
    }

    Corners {}

    Notification {
        id: notification
        bar: bar
    }
    PopupLauncher {}
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
