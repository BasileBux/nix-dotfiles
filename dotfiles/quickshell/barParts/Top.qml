import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ".."

BarPart {
    property var moduleSizes: [40]
    required property var notificationPanel

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
            implicitHeight: moduleSizes[0]
            Image {
                anchors.fill: parent
                anchors.margins: 5
                source: "../icons/nixos-original-logo.svg"
                fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                id: toggle
                anchors.fill: parent
                onClicked: {
                    bar.focusGrab.active = true;
                    notificationPanel.toggle();
                }
            }
        }
    }
}
