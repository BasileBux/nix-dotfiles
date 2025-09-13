import Quickshell
import QtQuick
import "launcher"
import "lock"

ShellRoot {
    id: shellRoot
    Wallpaper {}
    Bar {
        lock: lock
    }
    BottomLauncher {}
    Lock {
        id: lock
    }
}
