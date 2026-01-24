import Quickshell
import QtQuick
import "launcher"
import "lock"
import "notification"

ShellRoot {
    id: shellRoot
    Wallpaper {}
    Bar {
        lock: lock
    }
    // Notification {}
    // BottomLauncher {}
    PopupLauncher {}
    Lock {
        id: lock
    }
}
