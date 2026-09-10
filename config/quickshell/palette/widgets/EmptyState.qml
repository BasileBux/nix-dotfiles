import QtQuick
import "../.."
import "../../widgets" as Widgets

// The one empty state. Eight views used to park a bare Text in the middle of the
// glass; a zero-result list is still a surface, so it gets a real composition.
// Children span the full width and centre their own content: a Column positions
// its children, so anchors inside it would be ignored.
Column {
    id: root

    property string caption
    property string icon
    property string title

    spacing: Globals.space2
    width: 320

    Item {
        height: 36
        width: root.width

        Widgets.TintIcon {
            anchors.centerIn: parent
            color: Globals.theme.muted
            height: 32
            name: root.icon
            width: 32
        }
    }
    Text {
        color: Globals.theme.foreground
        font.family: Globals.theme.fontFamily
        font.pixelSize: Globals.fonts.lead
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        text: root.title
        visible: root.title !== ""
        width: root.width
    }
    Text {
        color: Globals.theme.muted
        font.family: Globals.theme.fontFamily
        font.pixelSize: Globals.fonts.caption
        horizontalAlignment: Text.AlignHCenter
        text: root.caption
        visible: root.caption !== ""
        width: root.width
        wrapMode: Text.WordWrap
    }
}
