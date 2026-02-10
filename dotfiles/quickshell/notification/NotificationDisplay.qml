import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import ".."

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "shell:notifications"
    focusable: false

    color: "transparent"

    property list<var> notifications

    onNotificationsChanged: {
        visible = notifications.length > 0;
    }

    function pushNotification(notification) {
        notification.handler = removeNotification;
        notification.closeTimer.running = true;
        notifications = [...notifications, notification];
    }

    function removeNotification(notification) {
        // notification.notif.tracked = false;
        notification.closeTimer.running = false;
        notifications = notifications.filter(n => n !== notification);
    }

    anchors {
        right: true
        top: true
    }

    margins {
        right: Globals.barWidth
        top: Globals.radius - 3
    }

    implicitWidth: Globals.notification.unitWidth
    // implicitHeight: Math.min(notificationListView.contentHeight, notificationHeight * maxVisible)
    implicitHeight: Globals.notification.unitHeight * Globals.notification.maxVisible + ((Globals.notification.maxVisible - 1) * Globals.spacing)

    visible: false

    ListView {
        id: notificationListView
        model: root.notifications
        spacing: Globals.spacing
        anchors.fill: parent

        interactive: false
        clip: true

        onCountChanged: {
            positionViewAtEnd();
        }

        delegate: NotificationItem {
            required property var modelData
            notification: modelData
            removeNotification: root.removeNotification
            wrapper: true

            height: Globals.notification.unitHeight
            width: Globals.notification.unitWidth
        }
    }
}
