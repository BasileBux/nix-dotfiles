import Quickshell
import QtQuick
import "../widgets" as Widgets
import ".."

Item {
    id: root
    required property var notification
    readonly property string iconSource: {
        if (notification.image)
            return notification.image;
        const icon = notification.appIcon || "";
        if (!icon)
            return "";
        if (icon.startsWith("/"))
            return "file://" + icon;
        if (icon.includes(":/"))
            return icon;
        return Quickshell.iconPath(icon, true);
    }
    Image {
        id: image
        anchors.centerIn: parent
        width: Math.min(parent.width, 28)
        height: Math.min(parent.height, 28)
        source: root.iconSource
        fillMode: Image.PreserveAspectFit
        visible: status === Image.Ready
    }
    Widgets.TintIcon {
        anchors.centerIn: parent
        width: 22
        height: 22
        name: "bell"
        color: Globals.theme.muted
        visible: image.status !== Image.Ready
    }
}
