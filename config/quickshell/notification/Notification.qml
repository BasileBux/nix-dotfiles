import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import ".."
import "../services" as Services

// Toast popups for incoming notifications. The persistent list lives in the
// palette's Notifications view; this only shows the transient bubbles.
//
// nix-shell -p libnotify
// notify-send "Hello" "This is a test notification from libnotify."

Item {
    id: root

    NotificationDisplay {
        id: notificationDisplay
    }
    Component {
        id: wrapperComponent

        NotificationWrapper {
        }
    }

    Connections {
        function dismissIfViewOpen() {
            if (PaletteState.visible && PaletteState.viewId === "notifications")
                notificationDisplay.dismissAll();
        }

        function onVisibleChanged() {
            dismissIfViewOpen();
        }

        function onViewIdChanged() {
            dismissIfViewOpen();
        }

        target: PaletteState
    }

    Connections {
        function onReceived(notification) {
            // Hidden while the notification center is open — it shows the
            // same list itself.
            if (Services.Notifications.doNotDisturb)
                return;
            if (PaletteState.visible && PaletteState.viewId === "notifications")
                return;

            if (Services.Notifications.audioEnabled) {
                let sound = notification.urgency === NotificationUrgency.Critical ? Globals.sounds.bigPing : Globals.sounds.smallPing;
                Globals.playSoundLoud(sound);
            }

            let wrapper = wrapperComponent.createObject(notificationDisplay);
            wrapper.notif = notification;

            notificationDisplay.pushNotification(wrapper);
        }

        target: Services.Notifications
    }
}
