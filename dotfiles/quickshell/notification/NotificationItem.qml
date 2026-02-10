import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import ".."

// Parent sets width and height additionally to the required stuff

Rectangle {
    id: root
    required property var notification
    required property var removeNotification
    required property bool wrapper

    property var notif: wrapper ? notification.notif : notification

    radius: Globals.radius
    border.color: Globals.theme.accent3

    color: Globals.theme.background

    Image {
        id: image
        anchors {
            left: parent.left
            leftMargin: Globals.spacing
            verticalCenter: parent.verticalCenter
        }
        source: notif.image == "" ? "../icons/nixos-original-logo.svg" : notif.image
        height: parent.height * 0.6
        width: parent.height * 0.6
    }

    Text {
        id: summary
        anchors {
            left: image.right
            leftMargin: Globals.spacing * 2
            top: image.top
            right: closeButton.left
        }
        maximumLineCount: 1
        color: Globals.theme.foreground
        text: notif.summary
        font.pixelSize: Globals.fonts.medium
        font.family: Globals.theme.fontFamily
        font.bold: true
        elide: Text.ElideRight
    }

    Text {
        id: body
        anchors {
            left: image.right
            leftMargin: Globals.spacing * 2
            top: summary.bottom
            right: closeButton.left
        }
        maximumLineCount: 3
        color: Globals.theme.foreground
        text: notif.body
        font.pixelSize: Globals.fonts.small
        font.family: Globals.theme.fontFamily
        wrapMode: Text.Wrap
        elide: Text.ElideRight
    }

    MouseArea {
        anchors.fill: parent
        // NOTE: Replace with action or meaningful interaction
        onClicked: root.removeNotification(notification)
    }

    Button {
        id: closeButton
        anchors {
            top: parent.top
            right: parent.right
        }
        background: Rectangle {
            color: "transparent"
        }
        icon.source: "../icons/cross.svg"
        icon.color: Globals.theme.foreground
        property int iconSize: 24
        icon.height: iconSize
        icon.width: iconSize
        onClicked: {
            notif.tracked = false;
            root.removeNotification(root.notification);
        }
    }
}
