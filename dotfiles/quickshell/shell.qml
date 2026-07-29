import Quickshell
import Quickshell.Services.Polkit
import QtQuick
import "launcher"
import "lock"
import "notification"
import "extras"

ShellRoot {
    id: shellRoot
    Wallpaper {}
    Bar {
        id: bar
        lock: lock
        notificationPanel: notification.notificationPanel
        notifDnd: notification.dnd
        notifCount: notification.notificationCount
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

    Remote {
        id: remote
    }
}
