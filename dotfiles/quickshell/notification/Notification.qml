import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// TODO:
// Display notification when receiving -> - to reduce, x to close
// Clicking popup notification does the first action if available
// Notifications panel to show all tracked notifications
// While in notification panel, new notifications should not pop up but be added to the list
// Possible to remove notifications from the panel
// Support for actions in notifications
// Support for different urgency levels

// TODO:
// First step: on notification, create a non clickable fullscreen PanelWindow which
// lets clicking at certain positions

// nix-shell -p libnotify
// notify-send "Hello" "This is a test notification from libnotify."

Item {
    NotificationServer {
        id: notificationServer

        function printList(list) {
            for (var i = 0; i < list.length; i++) {
                console.log("Item " + i + ": " + list[i]);
            }
        }
        persistenceSupported: true

        // BUG: ONLY FOR DEBUG
        keepOnReload: false

        onNotification: notification => {
            console.log("New notification:", notification.appName, "-", notification.summary, "-", notification.body);
            notification.tracked = true;
            notificationDisplay.pushNotification(notification);
            notificationDisplay.visible = true;
        }
    }
    NotificationDisplay {
        id: notificationDisplay
    }
}
