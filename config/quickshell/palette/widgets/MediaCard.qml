import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../../widgets" as Widgets
import "../.."
import "../../services" as Services

// Home media card: artwork, track info and transport controls. Purely a status
// display: clicking does nothing, scrolling adjusts volume.
Surface {
    id: root

    readonly property bool hasTrack: Services.Mpris.hasTrack
    readonly property var player: Services.Mpris.selected
    readonly property bool playing: Services.Mpris.playing

    WheelHandler {
        onWheel: event => Services.Audio.adjustVolume(event.angleDelta.y > 0)
    }
    RowLayout {
        anchors.fill: parent
        spacing: Globals.space2

        ClippingRectangle {
            Layout.preferredHeight: 64
            Layout.preferredWidth: 64
            color: root.hasTrack ? Globals.well : "transparent"
            radius: Globals.radius

            Image {
                anchors.fill: parent
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                source: root.player?.trackArtUrl || ""
                visible: root.hasTrack && source !== ""
            }
            Widgets.TintIcon {
                anchors.centerIn: parent
                color: Globals.theme.muted
                height: 32
                name: "play"
                visible: !root.hasTrack
                width: 32
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Globals.space1

            Text {
                Layout.fillWidth: true
                color: Globals.theme.foreground
                elide: Text.ElideRight
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.title
                font.weight: Font.DemiBold
                text: root.player?.trackTitle || "Nothing playing"
            }
            Text {
                Layout.fillWidth: true
                color: Globals.theme.muted
                elide: Text.ElideRight
                font.family: Globals.theme.fontFamily
                font.pixelSize: Globals.fonts.caption
                text: root.hasTrack ? (root.player?.trackArtist || "Unknown Artist") : "Press ▶ to start"
                visible: root.hasTrack
            }
        }

        // Transport controls
        RowLayout {
            spacing: Globals.space1
            visible: root.hasTrack

            IconButton {
                danger: false
                enabled: root.player?.canGoPrevious ?? false
                icon: "previous"
                size: 32

                onClicked: Services.Mpris.previous()
            }
            IconButton {
                enabled: root.playing ? (root.player?.canPause ?? false) : (root.player?.canPlay ?? false)
                icon: root.playing ? "pause" : "play"
                size: 32

                onClicked: Services.Mpris.togglePlay()
            }
            IconButton {
                enabled: root.player?.canGoNext ?? false
                icon: "next"
                size: 32

                onClicked: Services.Mpris.next()
            }
        }
    }
}
