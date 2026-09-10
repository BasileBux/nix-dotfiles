import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../widgets" as Widgets
import ".."

// One notification, used by the toast stack. The palette's Notifications view
// has its own card: a toast floats over arbitrary windows and needs a more
// opaque fill than a card sitting on the glass.
//
// Parent sets width and height additionally to the required stuff.
Rectangle {
    id: root

    property var notif: wrapper ? notification.notif : notification
    required property var notification
    required property var removeNotification
    readonly property bool critical: notif.urgency === NotificationUrgency.Critical
    required property bool wrapper

    border.color: cardMouse.containsMouse ? Globals.surfaceHoverBorder : Globals.surfaceBorder
    border.width: 1
    clip: true
    color: Globals.surfaceBackground
    radius: Globals.cardRadius

    // Declared first so the buttons below keep their own events: the topmost
    // item that accepts a press wins.
    MouseArea {
        id: cardMouse

        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            // Invoke the default action
            for (var i = 0; i < root.notif.actions.length; i++) {
                if (root.notif.actions[i].identifier === "default") {
                    root.notif.actions[i].invoke();
                    break;
                }
            }

            // Focus the sending app's window via Hyprland dispatch
            var desktopEntry = (root.notif.desktopEntry || "").toLowerCase();
            if (desktopEntry !== "") {
                for (var j = 0; j < Hyprland.toplevels.values.length; j++) {
                    var tl = Hyprland.toplevels.values[j];
                    if (tl.wayland && tl.wayland.appId.toLowerCase().includes(desktopEntry)) {
                        Hyprland.dispatch(`hl.dsp.focus({window = "address:0x${tl.address}"})`);
                        break;
                    }
                }
            }

            if (!root.notif.resident)
                root.removeNotification(root.notification);
        }
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Globals.margin
        anchors.rightMargin: Globals.margin
        anchors.topMargin: actionsRepeater.count > 0 ? Globals.space2 : Globals.margin
        anchors.bottomMargin: actionsRepeater.count > 0 ? Globals.space2 : Globals.margin
        spacing: Globals.space2

        SenderIcon {
            Layout.preferredHeight: 32
            Layout.preferredWidth: 32
            notification: root.notif
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
                    maximumLineCount: 1
                    text: root.notif.summary
                }
                Widgets.TintIcon {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    name: "warning"
                    color: Globals.colors.danger
                    visible: root.critical
                }
                Text {
                    text: "Urgent"
                    color: Globals.colors.dangerText
                    font.family: Globals.theme.fontFamily
                    font.pixelSize: Globals.fonts.micro
                    visible: root.critical
                }
            }
            Text {
                Layout.fillWidth: true
                color: Globals.theme.muted
                elide: Text.ElideRight
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.micro
                maximumLineCount: 1
                text: root.notif.appName || ""
                visible: (root.notif.appName || "") !== ""
            }
            Text {
                Layout.fillWidth: true
                color: Globals.theme.muted
                elide: Text.ElideRight
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.caption
                maximumLineCount: actionsRepeater.count > 0 ? 1 : 2
                text: root.notif.body
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Globals.space1
                visible: actionsRepeater.count > 0

                Repeater {
                    id: actionsRepeater

                    model: {
                        var acts = [];
                        for (var i = 0; i < root.notif.actions.length; i++) {
                            if (root.notif.actions[i].identifier !== "default")
                                acts.push(root.notif.actions[i]);
                        }
                        return acts;
                    }

                    delegate: Rectangle {
                        id: actionButton

                        readonly property bool hovered: actionMouse.containsMouse
                        required property var modelData

                        border.color: actionButton.hovered ? Globals.surfaceHoverBorder : "transparent"
                        border.width: 1
                        color: actionButton.hovered ? Globals.surfaceHover : Globals.surface
                        implicitHeight: 24
                        implicitWidth: actionLabel.implicitWidth + Globals.space2 * 2
                        radius: height / 2

                        Text {
                            id: actionLabel

                            anchors.centerIn: parent
                            color: Globals.theme.foreground
                            font.family: Globals.theme.fontFamily
                            font.pixelSize: Globals.fonts.caption
                            text: actionButton.modelData.text
                        }
                        MouseArea {
                            id: actionMouse

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                actionButton.modelData.invoke();
                                if (!root.notif.resident)
                                    root.removeNotification(root.notification);
                            }
                        }
                    }
                }
            }
        }
        Widgets.TintIcon {
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: 18
            Layout.preferredWidth: 18
            color: closeMouse.containsMouse ? Globals.theme.foreground : Globals.theme.muted
            name: "cross"

            MouseArea {
                id: closeMouse

                anchors.fill: parent
                anchors.margins: -Globals.space2
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: {
                    root.notif.tracked = false;
                    root.removeNotification(root.notification);
                }
            }
        }
    }
}
