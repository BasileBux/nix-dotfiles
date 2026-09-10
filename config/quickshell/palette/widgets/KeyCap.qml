import QtQuick
import "../.."

// Keyboard hint chip: a well-coloured 20 px square with the shortcut letter.
Rectangle {
    id: root

    property string key

    border.color: Globals.wellBorder
    border.width: 1
    color: Globals.well
    implicitHeight: 20
    implicitWidth: 20
    radius: Globals.radius

    Text {
        anchors.centerIn: parent
        color: Globals.theme.muted
        font.family: Globals.theme.fontFamily
        font.pixelSize: Globals.fonts.micro
        font.weight: Font.DemiBold
        text: root.key
    }
}
