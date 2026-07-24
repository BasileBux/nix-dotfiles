import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import "../widgets" as Widgets
import ".."

// Parent sets width and height additionally to the required stuff

Rectangle {
    id: root
    required property var notification
    required property var removeNotification
    required property bool wrapper

    property var notif: wrapper ? notification.notif : notification

    radius: Globals.radius

    readonly property color urgencyColor: {
        switch (notif.urgency) {
            case NotificationUrgency.Critical: return Globals.theme.accent1
            case NotificationUrgency.Low: return Globals.theme.muted
            default: return Globals.theme.accent3  // Normal
        }
    }
    border.color: urgencyColor
    color: Globals.theme.background

    readonly property string iconSource: {
        if (notif.image && notif.image !== "") return notif.image
        return "../icons/nixos-original-logo.svg"
    }

    Image {
        id: image
        anchors {
            left: parent.left
            leftMargin: Globals.spacing
            verticalCenter: parent.verticalCenter
        }
        source: root.iconSource
        height: parent.height * 0.6
        width: parent.height * 0.6
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: appName
        anchors {
            left: image.right
            leftMargin: Globals.spacing * 2
            top: summary.bottom
            topMargin: 1
            right: closeButton.left
        }
        text: notif.appName || ""
        color: Globals.theme.muted
        font.pixelSize: Globals.fonts.xsmall
        font.family: Globals.theme.fontFamily
        visible: text !== ""
        maximumLineCount: 1
        elide: Text.ElideRight
    }

    Text {
        id: summary
        anchors {
            left: image.right
            leftMargin: Globals.spacing * 2
            top: parent.top
            topMargin: Globals.spacing * 2
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
            top: appName.visible ? appName.bottom : summary.bottom
            topMargin: 2
            right: closeButton.left
        }
        maximumLineCount: 2
        color: Globals.theme.foreground
        text: notif.body
        font.pixelSize: Globals.fonts.small
        font.family: Globals.theme.fontFamily
        wrapMode: Text.Wrap
        elide: Text.ElideRight
    }

    // Action buttons row, excludes "default"
    Row {
        id: actionsRow
        anchors {
            left: image.right
            leftMargin: Globals.spacing * 2
            right: closeButton.left
            bottom: parent.bottom
            bottomMargin: Globals.spacing
        }
        spacing: Globals.spacing

        Repeater {
            model: {
                var acts = [];
                for (var i = 0; i < notif.actions.length; i++) {
                    if (notif.actions[i].identifier !== "default") {
                        acts.push(notif.actions[i]);
                    }
                }
                return acts;
            }

            delegate: Rectangle {
                height: 22
                width: btnText.implicitWidth + Globals.spacing * 4
                radius: 4
                color: Globals.theme.accent2

                Text {
                    id: btnText
                    anchors.centerIn: parent
                    text: modelData.text
                    color: Globals.theme.foreground
                    font.pixelSize: Globals.fonts.xsmall
                    font.family: Globals.theme.fontFamily
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        modelData.invoke();
                        if (!notif.resident) {
                            root.removeNotification(root.notification);
                        }
                    }
                }
            }
        }
    }

    // Body click -> default action + focus window
    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Invoke the default action
            for (var i = 0; i < notif.actions.length; i++) {
                if (notif.actions[i].identifier === "default") {
                    notif.actions[i].invoke();
                    break;
                }
            }

            // Focus the sending app's window via Hyprland dispatch
            var desktopEntry = (notif.desktopEntry || "").toLowerCase();
            if (desktopEntry !== "") {
                for (var j = 0; j < Hyprland.toplevels.values.length; j++) {
                    var tl = Hyprland.toplevels.values[j];
                    if (tl.wayland && tl.wayland.appId.toLowerCase().includes(desktopEntry)) {
                        Hyprland.dispatch(`hl.dsp.focus({window = "address:0x${tl.address}"})`);
                        break;
                    }
                }
            }

            if (!notif.resident) {
                root.removeNotification(root.notification);
            }
        }
    }

    Item {
        id: closeButton
        anchors {
            top: parent.top
            right: parent.right
        }
        property int iconSize: 24
        width: iconSize
        height: iconSize

        Widgets.TintIcon {
            anchors.fill: parent
            source: "../icons/cross.svg"
            color: Globals.theme.foreground
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                notif.tracked = false;
                root.removeNotification(root.notification);
            }
        }
    }
}
