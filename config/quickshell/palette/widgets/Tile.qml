import QtQuick
import QtQuick.Layouts
import "../.."
import "../../widgets" as Widgets

// The whole tile is interactive; the icon is not a separate nested button.
Surface {
    id: tile

    property string caption
    property string icon
    // Optional widget replacing the icon inside the well (battery ring, …).
    property Component iconComponent
    property int iconSize: 30
    property string value
    property color valueColor: Globals.theme.foreground
    property int valueSize: Globals.fonts.lead
    property int wellSize: 40

    interactive: true

    RowLayout {
        anchors.fill: parent
        spacing: Globals.space2

        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: tile.wellSize
            Layout.preferredWidth: tile.wellSize

            Loader {
                anchors.centerIn: parent
                height: parent.height - Globals.space2
                sourceComponent: tile.iconComponent
                visible: tile.iconComponent !== null
                width: parent.width - Globals.space2
            }
            Widgets.TintIcon {
                anchors.centerIn: parent
                color: tile.valueColor
                height: tile.iconSize
                name: tile.icon
                visible: tile.iconComponent === null
                width: tile.iconSize
            }
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: Globals.space1

            Text {
                Layout.fillWidth: true
                color: tile.valueColor
                elide: Text.ElideRight
                font.family: Globals.theme.fontFamily
                font.pixelSize: tile.valueSize
                font.weight: Font.DemiBold
                text: tile.value
            }
            Text {
                Layout.fillWidth: true
                color: Globals.theme.muted
                elide: Text.ElideRight
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.caption
                text: tile.caption
            }
        }
    }
}
