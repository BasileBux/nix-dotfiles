import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import ".."

// nix-shell -p libnotify
// notify-send "Hello" "This is a test notification from libnotify."

Item {
    id: root
    property alias notificationPanel: panel
    required property var bar

    readonly property alias dnd: notificationServer.doNotDisturb
    readonly property int notificationCount: notificationServer.trackedNotifications.values.length
    NotificationServer {
        id: notificationServer

        bodyHyperlinksSupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        actionIconsSupported: true
        inlineReplySupported: true
        bodySupported: true
        persistenceSupported: true
        imageSupported: true
        actionsSupported: true

        property bool doNotDisturb: false

        property bool audioEnabled: true

        onNotification: notification => {
            notification.tracked = true;

            if (!panel.shown && !doNotDisturb) {
                let soundPath = Quickshell.shellDir + "/sounds/";
                if (audioEnabled) {
                    let sound = notification.urgency === NotificationUrgency.Critical ? soundPath + "complete.oga" : soundPath + "message.oga";
                    Quickshell.execDetached(["pw-play", sound]);
                }

                let wrapper = Qt.createQmlObject('import Quickshell; import QtQuick; NotificationWrapper { }', notificationServer);
                wrapper.notif = notification;

                notificationDisplay.pushNotification(wrapper);
            }
        }
    }
    NotificationDisplay {
        id: notificationDisplay
    }
    Item {
        Popup {
            id: panel
            topRight: true
            popupWidth: Globals.notification.unitWidth + (Globals.padding * 8)
            popupHeight: Globals.notification.unitHeight * 7 + (Globals.padding * 2)
            yPos: 0
            name: "NotificationPanel"
            ref: root.bar
            onShownChanged: {
                notificationDisplay.notifications = [];
            }
            NotificationPanel {
                id: panelContent
                notificationServer: notificationServer
            }
        }
    }
}
