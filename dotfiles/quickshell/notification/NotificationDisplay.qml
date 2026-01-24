import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "shell:notifications"
    focusable: false

    color: "transparent"

    property list<Notification> notifications

    onNotificationsChanged: {
        visible = notifications.length > 0;
    }

    function pushNotification(notification) {
        notifications = [...notifications, notification];
        console.log("Pushed notification. Total notifications:", notifications.length);
    }

    function removeNotification(notification) {
        notification.tracked = false;
        notifications = notifications.filter(n => n !== notification);
    }

    property int notificationWidth: 400
    property int notificationHeight: 150

    anchors {
        right: true
        top: true
    }
    implicitWidth: notificationWidth
    implicitHeight: notificationHeight * notifications.length

    visible: false

    ListView {
        id: notificationListView
        model: root.notifications
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        implicitWidth: root.notificationWidth

        delegate: Component {
            Rectangle {
                property Notification notification: modelData
                color: "lightgray"
                anchors.right: parent.right
                implicitHeight: notificationHeight
                implicitWidth: notificationWidth
                Text {
                    anchors.centerIn: parent
                    text: notification.appName + "\n" + notification.summary + "\n" + notification.body
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        removeNotification(notification);
                    }
                }
            }
        }
    }
}
