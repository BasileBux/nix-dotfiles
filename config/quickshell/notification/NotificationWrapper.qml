import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import ".."

QtObject {
    id: root

    property Timer closeTimer: Timer {
        interval: root.duration > 0 ? root.duration : Globals.notification.timeoutMs
        repeat: false
        running: false

        onTriggered: {
            if (root.duration > 0)
                root.handler(root);
        }
    }
    // expireTimeout: >0 = ms, 0 = never expire, -1 = server default
    readonly property int duration: notif && notif.expireTimeout > 0 ? notif.expireTimeout : (notif && notif.expireTimeout === 0 ? 0 : Globals.notification.timeoutMs)
    property var handler: null // Function to call on closeTimer trigger

    property Notification notif: null
}
