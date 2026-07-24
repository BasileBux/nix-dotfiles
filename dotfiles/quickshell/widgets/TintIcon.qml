import QtQuick
import QtQuick.Controls

Item {
    property alias source: btn.icon.source
    property alias color: btn.icon.color

    Button {
        id: btn
        anchors.fill: parent
        background: Item { }
        icon.width: parent.width
        icon.height: parent.height
    }
}
