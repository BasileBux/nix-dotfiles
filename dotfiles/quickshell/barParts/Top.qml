import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../widgets" as Widgets
import ".."

BarPart {
    required property var notificationPanel
    required property bool dnd
    required property int notifCount

    ColumnLayout {
        id: layout
        spacing: Globals.spacing
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        uniformCellSizes: false

        Item {
            id: notificationsModule
            Layout.fillWidth: true
            implicitHeight: 40

            // Bell icon
            Widgets.TintIcon {
                anchors.fill: parent
                anchors.margins: 5
                source: "../icons/bell.svg"
                color: Globals.theme.foreground
                opacity: dnd ? 0.45 : 1.0
            }

            // Notification count badge
            Rectangle {
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: 3
                    rightMargin: 2
                }
                width: 16
                height: 16
                radius: 8
                color: Globals.theme.accent1
                visible: notifCount > 0

                Text {
                    anchors.centerIn: parent
                    text: notifCount > 99 ? "99+" : notifCount.toString()
                    color: Globals.theme.foreground
                    font.pixelSize: Globals.fonts.tiny
                    font.family: Globals.theme.fontFamily
                    font.bold: true
                }
            }

            MouseArea {
                id: toggle
                anchors.fill: parent
                onClicked: {
                    bar.focusGrab.active = !bar.focusGrab.active;
                    notificationPanel.toggle();
                }
            }
        }
    }
}
