import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services
import Quickshell.Services.Mpris
import ".."

Item {
    id: root
    anchors {
        fill: parent
        leftMargin: Globals.spacing
        rightMargin: Globals.spacing
    }

    readonly property string preferedPlayerDBusName: "org.mpris.MediaPlayer2.firefox"
    readonly property var mprisPlayers: Mpris.players.values
    property MprisPlayer preferedPlayer: null

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Item {
            id: trackInfo
            Layout.fillWidth: true
            implicitHeight: 190
            RowLayout {
                anchors.fill: parent
                spacing: Globals.spacing
                ClippingRectangle {
                    id: trackArt
                    Layout.fillHeight: true
                    implicitWidth: height
                    radius: Globals.radius
                    Image {
                        source: preferedPlayer === null || preferedPlayer.trackArtUrl == "" ? "../icons/track-art-placehoder.png" : preferedPlayer.trackArtUrl
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }
                ColumnLayout {
                    id: trackDetails
                    Layout.fillHeight: true
                    spacing: 0
                    Item {
                        // Spacer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    Text {
                        id: trackTitle
                        Layout.fillWidth: true
                        text: preferedPlayer === null ? "" : preferedPlayer.trackTitle
                        font.pixelSize: 20
                        font.family: Globals.theme.fontFamily
                        font.bold: true
                        horizontalAlignment: Text.AlignLeft
                        color: Globals.theme.foreground
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }
                    Text {
                        id: trackArtist
                        Layout.fillWidth: true
                        text: preferedPlayer === null ? "" : (preferedPlayer.trackArtist === "" ? "Unknown Artist" : preferedPlayer.trackArtist)
                        font.pixelSize: 16
                        font.family: Globals.theme.fontFamily
                        horizontalAlignment: Text.AlignLeft
                        color: Globals.theme.foreground
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }
                    Text {
                        id: trackAlbum
                        Layout.fillWidth: true
                        text: preferedPlayer === null ? "" : (preferedPlayer.trackAlbum === "" ? "Unknown Album" : preferedPlayer.trackAlbum)
                        font.pixelSize: 14
                        font.family: Globals.theme.fontFamily
                        horizontalAlignment: Text.AlignLeft
                        color: Globals.theme.border
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }
                }
            }
        }
        Item { // Spacer
            Layout.fillWidth: true
            implicitHeight: Globals.spacing * 2
        }
        Item {
            Layout.fillWidth: true
            implicitHeight: 40
            RowLayout {
                id: controls
                // Layout.fillHeight: true
                anchors.fill: parent

                Item {
                    // Spacer
                    Layout.fillWidth: true
                }
                Button {
                    id: previousButton
                    background: Rectangle {
                        color: "transparent"
                    }
                    icon.source: "../icons/previous.svg"
                    icon.color: {
                        if (root.preferedPlayer === null || root.preferedPlayer.canGoPrevious === false) {
                            Globals.theme.muted;
                        } else {
                            Globals.theme.foreground;
                        }
                    }
                    icon.height: parent.height * 0.7
                    icon.width: parent.height * 0.7
                    enabled: preferedPlayer !== null
                    onClicked: {
                        if (root.preferedPlayer !== null && root.preferedPlayer.canGoPrevious) {
                            root.preferedPlayer.previous();
                        }
                    }
                }
                Button {
                    id: playPauseButton
                    background: Rectangle {
                        color: "transparent"
                    }
                    icon.source: {
                        if (root.preferedPlayer === null) {
                            "../icons/play.svg";
                        } else {
                            if (root.preferedPlayer.playbackState === MprisPlaybackState.Playing) {
                                "../icons/pause.svg";
                            } else {
                                "../icons/play.svg";
                            }
                        }
                    }
                    icon.color: {
                        if (root.preferedPlayer === null || (root.preferedPlayer.canPause === false && root.preferedPlayer.playbackState === MprisPlaybackState.Playing) || (root.preferedPlayer.canPlay === false && root.preferedPlayer.playbackState !== MprisPlaybackState.Playing)) {
                            Globals.theme.muted;
                        } else {
                            Globals.theme.foreground;
                        }
                    }
                    icon.height: parent.height * 0.7
                    icon.width: parent.height * 0.7
                    enabled: preferedPlayer !== null
                    onClicked: {
                        if (root.preferedPlayer !== null) {
                            if (root.preferedPlayer.playbackState === MprisPlaybackState.Playing && root.preferedPlayer.canPause) {
                                root.preferedPlayer.pause();
                            } else if (root.preferedPlayer.playbackState !== MprisPlaybackState.Playing && root.preferedPlayer.canPlay) {
                                root.preferedPlayer.play();
                            }
                        }
                    }
                }
                Button {
                    id: nextButton
                    background: Rectangle {
                        color: "transparent"
                    }
                    icon.source: "../icons/next.svg"
                    icon.color: {
                        if (root.preferedPlayer === null || root.preferedPlayer.canGoNext === false) {
                            Globals.theme.muted;
                        } else {
                            Globals.theme.foreground;
                        }
                    }
                    icon.height: parent.height * 0.7
                    icon.width: parent.height * 0.7
                    enabled: preferedPlayer !== null
                    onClicked: {
                        if (root.preferedPlayer !== null && root.preferedPlayer.canGoNext) {
                            root.preferedPlayer.next();
                        }
                    }
                }
                Item {
                    // Spacer
                    Layout.fillWidth: true
                }
            }
        }
        Item { // Spacer
            Layout.fillWidth: true
            implicitHeight: Globals.spacing * 2
        }
        Item {
            id: prgressBar
            Layout.fillWidth: true
            Layout.fillHeight: true
            Slider {
                id: timeSlider
                anchors.fill: parent
                from: 0
                value: root.preferedPlayer === null || !root.preferedPlayer.positionSupported ? 0 : root.preferedPlayer.position
                to: root.preferedPlayer !== null && root.preferedPlayer.lengthSupported ? root.preferedPlayer.length : 0
                enabled: root.preferedPlayer !== null && root.preferedPlayer.positionSupported && root.preferedPlayer.canSeek
                onMoved:
                // Seek
                {}
                onPressedChanged: {
                    if (root.preferedPlayer === null || !root.preferedPlayer.positionSupported || !root.preferedPlayer.canSeek) {
                        return;
                    }
                    if (!pressed) {
                        root.preferedPlayer.position = timeSlider.value;
                    }
                }

                background: Rectangle {
                    color: Globals.theme.muted
                    implicitWidth: 10
                    implicitHeight: 4
                    width: timeSlider.availableWidth
                    height: implicitHeight
                    radius: height / 2

                    Rectangle {
                        color: Globals.theme.foreground
                        width: timeSlider.visualPosition * parent.width
                        height: parent.height
                        radius: height / 2
                    }
                }

                handle: Rectangle {
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: width / 2
                    color: "transparent"
                }
            }
        }
    }

    function findPreferedPlayer() {
        for (let player of Mpris.players.values) {
            if (player.dbusName.startsWith(preferedPlayerDBusName)) {
                return player;
            }
        }
        return null;
    }

    onMprisPlayersChanged: {
        if (root.preferedPlayer === null) {
            root.preferedPlayer = findPreferedPlayer();
        }
    }
}
