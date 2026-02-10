import Quickshell
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
    Notification {
        id: notification
        bar: bar
    }
    // BottomLauncher {}
    PopupLauncher {}
    Lock {
        id: lock
    }
}
