import QtQuick
import QtQuick.Layouts
import "../widgets" as PWidgets
import "../../widgets" as Widgets
import "../.."

Item {
    id: root

    function handleKey(event) {
        if (event.key === Qt.Key_S) {
            PaletteState.shutdown();
            event.accepted = true;
        } else if (event.key === Qt.Key_R) {
            PaletteState.reboot();
            event.accepted = true;
        } else if (event.key === Qt.Key_O) {
            PaletteState.logout();
            event.accepted = true;
        } else if (event.key === Qt.Key_L) {
            PaletteState.lockScreen();
            event.accepted = true;
        }
    }

    // Destructive actions are the only cards that go red, and they never go
    // accent: "hover = red for everything" was the old bug.
    component PowerCard: PWidgets.Surface {
        id: card

        property bool destructive: false
        property string icon
        property string key
        property string label

        fill: card.destructive && card.hovered ? Qt.rgba(Globals.colors.danger.r, Globals.colors.danger.g, Globals.colors.danger.b, 0.12) : "transparent"
        interactive: true
        Layout.fillWidth: true
        Layout.preferredHeight: 160
        Layout.preferredWidth: 160
        cornerRadius: Globals.cardRadius

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Globals.space2

            Widgets.TintIcon {
                Layout.alignment: Qt.AlignHCenter
                color: card.destructive && card.hovered ? Globals.colors.danger : card.hovered ? Globals.accent : Globals.theme.foreground
                height: 36
                name: card.icon
                width: 36
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                color: card.destructive && card.hovered ? Globals.colors.danger : card.hovered ? Globals.accent : Globals.theme.foreground
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.body
                font.weight: Font.Medium
                text: card.label
            }
            PWidgets.KeyCap {
                Layout.alignment: Qt.AlignHCenter
                key: card.key
            }
        }
    }

    Item {
        anchors.fill: parent

        RowLayout {
            anchors.centerIn: parent
            spacing: Globals.margin

            Repeater {
                model: [
                    {
                        icon: "shutdown",
                        label: "Shut down",
                        key: "S",
                        exec: PaletteState.shutdown,
                        danger: true
                    },
                    {
                        icon: "reboot",
                        label: "Reboot",
                        key: "R",
                        exec: PaletteState.reboot,
                        danger: true
                    },
                    {
                        icon: "logout",
                        label: "Log out",
                        key: "O",
                        exec: PaletteState.logout,
                        danger: true
                    },
                    {
                        icon: "lock",
                        label: "Lock",
                        key: "L",
                        exec: PaletteState.lockScreen,
                        danger: false
                    }
                ]

                delegate: PowerCard {
                    required property var modelData

                    destructive: modelData.danger
                    icon: modelData.icon
                    key: modelData.key
                    label: modelData.label

                    onClicked: modelData.exec()
                }
            }
        }
    }
}
