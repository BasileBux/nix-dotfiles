import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import ".."

Item {
    id: root
    anchors.fill: parent

    required property NotificationServer notificationServer
    property list<var> notifications: notificationServer.trackedNotifications.values

    function removeNotification(notification) {
    }

    Rectangle {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        implicitHeight: 30
        color: Globals.theme.background
        z: 1000

        Button {
            id: clearAllButton
            anchors {
                right: parent.right
                rightMargin: Globals.spacing
                verticalCenter: parent.verticalCenter
            }
            implicitWidth: header.height
            implicitHeight: header.height
            background: Rectangle {
                color: "transparent"
            }
            icon {
                source: "../icons/xmarked-list.svg"
                width: height * 0.8
                height: height * 0.8
                color: Globals.theme.foreground
            }
            onClicked: {
                for (let i = root.notifications.length - 1; i >= 0; i--) {
                    root.notifications[i].tracked = false;
                }
            }
        }

        Button {
            id: doNotDisturbButton
            anchors {
                left: parent.left
                leftMargin: Globals.spacing
                verticalCenter: parent.verticalCenter
            }
            implicitWidth: header.height
            implicitHeight: header.height
            background: Rectangle {
                color: root.notificationServer.doNotDisturb ? Globals.theme.accent1 : "transparent"
                radius: Globals.radius
            }
            icon {
                source: "../icons/moon.svg"
                width: height * 0.9
                height: height * 0.9
                color: Globals.theme.foreground
            }
            onClicked: {
                root.notificationServer.doNotDisturb = !root.notificationServer.doNotDisturb;
            }
        }
    }

    ListView {
        id: notificationListView
        model: root.notifications
        spacing: Globals.spacing
        implicitWidth: Globals.notification.unitWidth
        clip: true
        anchors {
            top: header.bottom
            topMargin: Globals.spacing * 2
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }

        delegate: NotificationItem {
            required property var modelData
            notification: modelData
            removeNotification: root.removeNotification
            wrapper: false

            height: Globals.notification.unitHeight
            width: Globals.notification.unitWidth
        }
    }
}
