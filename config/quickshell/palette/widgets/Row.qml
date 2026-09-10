import QtQuick
import QtQuick.Layouts
import "../.."
import "../../widgets" as Widgets

Item {
    id: root

    property string caption
    property bool dimmed: false
    property string icon
    property string imageUrl
    property bool iconWell: false
    property bool selected: false
    property string title
    property int iconSize: 24

    default property alias trailing: trailingSlot.data
    property alias leading: leadingSlot.data
    readonly property bool hovered: ma.containsMouse

    signal clicked
    signal hover

    height: 44
    implicitWidth: layout.implicitWidth + Globals.margin * 2
    width: ListView.view ? ListView.view.width : implicitWidth

    Rectangle {
        anchors.fill: parent
        border.color: root.hovered ? Globals.surfaceHoverBorder : "transparent"
        border.width: 1
        color: root.selected ? root.hovered ? Qt.rgba(Globals.accent.r, Globals.accent.g, Globals.accent.b, 0.22) : Globals.accentFill : root.hovered ? Globals.surfaceHover : "transparent"
        radius: Globals.radius
        Behavior on color {
            ColorAnimation {
                duration: Globals.motionHover
                easing.type: Easing.OutCubic
            }
        }
    }
    // Selection never participates in the content spacing.
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: Globals.space2
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: 20
        radius: 1
        color: Globals.accent
        visible: root.selected
    }
    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: Globals.margin
        anchors.rightMargin: Globals.space2
        anchors.topMargin: Globals.space1
        anchors.bottomMargin: Globals.space1
        spacing: Globals.space2

        Item {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            visible: root.icon !== "" || root.imageUrl !== "" || leadingSlot.children.length > 0

            Rectangle {
                anchors.fill: parent
                border.color: Globals.wellBorder
                border.width: 1
                color: Globals.well
                radius: Globals.radius
                visible: root.iconWell
            }
            Widgets.TintIcon {
                anchors.centerIn: parent
                color: root.dimmed ? Globals.theme.muted : Globals.theme.foreground
                height: root.iconSize
                width: root.iconSize
                name: root.icon
                visible: root.imageUrl === "" && root.icon !== ""
            }
            Image {
                anchors.centerIn: parent
                width: root.iconSize
                height: root.iconSize
                asynchronous: false
                fillMode: Image.PreserveAspectFit
                source: root.imageUrl
                sourceSize.width: 40
                sourceSize.height: 40
                visible: root.imageUrl !== ""
            }
            Item {
                id: leadingSlot
                anchors.centerIn: parent
                width: childrenRect.width
                height: childrenRect.height
            }
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: Globals.flush
            Text {
                Layout.fillWidth: true
                color: root.dimmed ? Globals.theme.muted : Globals.theme.foreground
                elide: Text.ElideRight
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.body
                font.weight: root.selected ? Font.Medium : Font.Normal
                text: root.title
            }
            Text {
                Layout.fillWidth: true
                color: Globals.theme.muted
                elide: Text.ElideRight
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.caption
                visible: root.caption !== ""
                text: root.caption
            }
        }
        RowLayout {
            id: trailingSlot
            Layout.alignment: Qt.AlignVCenter
            spacing: Globals.space1
        }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
        onEntered: root.hover()
    }
}
