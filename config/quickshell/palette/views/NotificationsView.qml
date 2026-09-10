import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../widgets" as PWidgets
import "../../services" as Services
import "../.."
import "../../notification" as NotificationWidgets
import "../../widgets" as Widgets

Item {
    id: root

    readonly property var notifications: Services.Notifications.tracked

    function handleKey(event) {
        if (event.key === Qt.Key_Backspace && root.notifications.length > 0) {
            Globals.playSound(Globals.sounds.pageTurn);
            Services.Notifications.clearAll();
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            scroll(-1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            scroll(1);
            event.accepted = true;
        }
    }
    function removeNotification(notification) {
        notification.tracked = false;
    }

    function scroll(rows) {
        const row = Globals.notification.unitHeight + Globals.space1;
        notificationListView.contentY = Math.max(0, Math.min(notificationListView.contentY + rows * row, notificationListView.contentHeight - notificationListView.height));
        notificationListView.returnToBounds();
    }

    // Same interaction as the toast: run the default action, focus the sender.
    function activateNotification(notification) {
        for (var i = 0; i < notification.actions.length; i++) {
            if (notification.actions[i].identifier === "default") {
                notification.actions[i].invoke();
                break;
            }
        }
        var desktopEntry = (notification.desktopEntry || "").toLowerCase();
        if (desktopEntry !== "") {
            for (var j = 0; j < Hyprland.toplevels.values.length; j++) {
                var tl = Hyprland.toplevels.values[j];
                if (tl.wayland && tl.wayland.appId.toLowerCase().includes(desktopEntry)) {
                    Hyprland.dispatch(`hl.dsp.focus({window = "address:0x${tl.address}"})`);
                    break;
                }
            }
        }
        if (!notification.resident)
            root.removeNotification(notification);
    }

    // Ordinary notifications are calm; only critical ones need an urgency badge.
    component NotificationCard: PWidgets.Surface {
        id: card

        required property var notification

        readonly property bool critical: notification.urgency === NotificationUrgency.Critical

        interactive: true
        nested: true
        padding: Globals.margin

        onClicked: root.activateNotification(card.notification)

        RowLayout {
            anchors.fill: parent
            spacing: Globals.space2

            NotificationWidgets.SenderIcon {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 32
                notification: card.notification
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Globals.space1

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Globals.space1
                    Text {
                        Layout.fillWidth: true
                        color: Globals.theme.foreground
                        elide: Text.ElideRight
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.body
                        font.weight: Font.DemiBold
                        text: card.notification.summary
                    }
                    Widgets.TintIcon {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        name: "warning"
                        color: Globals.colors.danger
                        visible: card.critical
                    }
                    Text {
                        text: "Urgent"
                        color: Globals.colors.dangerText
                        font.family: Globals.theme.fontFamily
                        font.pixelSize: Globals.fonts.micro
                        visible: card.critical
                    }
                }
                Text {
                    Layout.fillWidth: true
                    color: Globals.theme.muted
                    elide: Text.ElideRight
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.micro
                    text: card.notification.appName || ""
                    visible: (card.notification.appName || "") !== ""
                }
                Text {
                    Layout.fillWidth: true
                    color: Globals.theme.muted
                    elide: Text.ElideRight
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.caption
                    maximumLineCount: 2
                    text: card.notification.body
                    wrapMode: Text.Wrap
                }
            }
            PWidgets.IconButton {
                Layout.alignment: Qt.AlignTop
                icon: "cross"
                iconSize: 18
                size: 24
                tooltip: "Dismiss notification"

                onClicked: root.removeNotification(card.notification)
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: Globals.space2

        ColumnLayout {
            anchors.fill: parent
            spacing: Globals.space2

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                spacing: Globals.space1

                PWidgets.IconButton {
                    active: Services.Notifications.doNotDisturb
                    icon: "moon"
                    size: 32
                    tooltip: Services.Notifications.doNotDisturb ? "Disable do not disturb" : "Enable do not disturb"

                    onClicked: {
                        Services.Notifications.doNotDisturb = !Services.Notifications.doNotDisturb;
                        Globals.playSound(Globals.sounds.click);
                    }
                }
                PWidgets.IconButton {
                    active: Services.Notifications.audioEnabled
                    icon: Services.Notifications.audioEnabled ? "bell" : "muted-bell"
                    size: 32
                    tooltip: Services.Notifications.audioEnabled ? "Mute notification sounds" : "Enable notification sounds"

                    onClicked: {
                        Services.Notifications.audioEnabled = !Services.Notifications.audioEnabled;
                        Globals.playSound(Globals.sounds.click);
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                Widgets.PillButton {
                    enabled: root.notifications.length > 0
                    text: "Clear all"

                    onClicked: {
                        Globals.playSound(Globals.sounds.pageTurn);
                        Services.Notifications.clearAll();
                    }
                }
            }

            ListView {
                id: notificationListView

                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                model: root.notifications
                spacing: Globals.space1
                visible: count > 0

                delegate: NotificationCard {
                    required property int index
                    required property var modelData

                    height: 96
                    notification: modelData
                    width: ListView.view.width
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: root.notifications.length === 0

                PWidgets.EmptyState {
                    anchors.centerIn: parent
                    caption: Services.Notifications.doNotDisturb ? "Do not disturb is on" : "Do not disturb is off"
                    icon: "bell"
                    title: "No notifications"
                }
            }
        }
    }
}
