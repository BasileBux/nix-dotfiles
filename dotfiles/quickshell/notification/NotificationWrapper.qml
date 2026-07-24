import Quickshell
import Quickshell.Services.Notifications
import QtQuick

QtObject {
    id: root
    property Notification notif: null
    // expireTimeout: >0 = ms, 0 = never expire, -1 = server default -> use 5000
    readonly property int duration: notif && notif.expireTimeout > 0 ? notif.expireTimeout
        : (notif && notif.expireTimeout === 0 ? 0 : 5000)

    property var handler: null // Function to call on closeTimer trigger

    property Timer closeTimer: Timer {
        interval: root.duration > 0 ? root.duration : 5000
        repeat: false
        running: false
        onTriggered: {
            if (root.duration > 0) root.handler(root);
        }
    }
}
