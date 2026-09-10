pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import ".."

Singleton {
    id: root

    property bool audioEnabled: true
    readonly property int count: server.trackedNotifications.values.length
    property bool doNotDisturb: false
    readonly property alias server: server
    readonly property var tracked: server.trackedNotifications.values

    signal received(var notification)

    function clearAll() {
        for (let i = root.tracked.length - 1; i >= 0; i--)
            root.tracked[i].tracked = false;
    }

    NotificationServer {
        id: server

        actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        inlineReplySupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;
            root.received(notification);
        }
    }
}
