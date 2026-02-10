import Quickshell
import Quickshell.Services.Notifications
import QtQuick

QtObject {
    id: root
    property Notification notif: null
    property int duration: 5000 // Duration in milliseconds

    property var handler: null // Function to call on closeTimer trigger

    property Timer closeTimer: Timer {
        interval: root.duration
        repeat: false
        running: false
        onTriggered: root.handler(root)
    }
}
