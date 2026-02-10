import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import ".."

// TODO:
// Support for actions in notifications
// Support for different urgency levels

// nix-shell -p libnotify
// notify-send "Hello" "This is a test notification from libnotify."

Item {
    id: root
    property alias notificationPanel: panel
    required property var bar
    NotificationServer {
        id: notificationServer

        function printList(list) {
            for (var i = 0; i < list.length; i++) {
                console.log("Item " + i + ": " + list[i]);
            }
        }

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

        onNotification: notification => {
            notification.tracked = true;

            if (!panel.shown && !doNotDisturb) {
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
        TopRightPopup {
            id: panel
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
