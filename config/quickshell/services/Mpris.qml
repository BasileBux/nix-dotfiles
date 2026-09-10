pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Single selected MPRIS player, shared by the Home media card and any future
// view. Selection prefers Firefox, then any player with a track; a player
// keeps selection until its track disappears. MprisPlayer.position does not
// notify on change, so a 1s timer re-polls it while a track is playing.
Singleton {
    id: root

    readonly property bool hasTrack: selected !== null && selected.trackTitle !== ""
    readonly property var players: Mpris.players.values
    readonly property bool playing: hasTrack && selected.playbackState === MprisPlaybackState.Playing

    // Polled position, so views can bind without stale-notify issues.
    property real position: 0
    readonly property string preferedPlayerDBusName: "org.mpris.MediaPlayer2.firefox"
    property MprisPlayer selected: null

    function next() {
        if (root.selected !== null && root.selected.canGoNext)
            root.selected.next();
    }
    function previous() {
        if (root.selected !== null && root.selected.canGoPrevious)
            root.selected.previous();
    }
    function seek(position: real) {
        if (root.selected !== null && root.selected.canSeek) {
            root.selected.position = position;
            root.position = position;
        }
    }
    function selectPlayer() {
        // Sticky: keep the current player while it still has content.
        if (root.selected !== null && root.selected.trackTitle !== "") {
            if (Mpris.players.values.includes(root.selected))
                return;
            root.selected = null;
        }

        const players = Mpris.players.values;

        // Firefox with actual content
        for (let i = 0; i < players.length; ++i) {
            const p = players[i];
            if (p.dbusName.startsWith(root.preferedPlayerDBusName) && p.trackTitle !== "") {
                root.selected = p;
                return;
            }
        }
        // Any other player with content
        for (let i = 0; i < players.length; ++i) {
            if (players[i].trackTitle !== "") {
                root.selected = players[i];
                return;
            }
        }
        // Nothing playing anywhere
        root.selected = null;
    }
    function togglePlay() {
        if (root.selected === null)
            return;
        if (root.playing && root.selected.canPause)
            root.selected.pause();
        else if (!root.playing && root.selected.canPlay)
            root.selected.play();
    }

    Component.onCompleted: selectPlayer()
    onPlayersChanged: selectPlayer()
    onSelectedChanged: root.position = selected?.position ?? 0

    Timer {
        interval: 1000
        repeat: true
        running: root.playing

        onTriggered: root.position = root.selected.position
    }

    // trackTitle changes on an existing player don't fire playersChanged.
    Timer {
        interval: 2000
        repeat: true
        running: true

        onTriggered: root.selectPlayer()
    }
}
