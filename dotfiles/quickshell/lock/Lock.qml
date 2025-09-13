import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Hyprland

Scope {
    id: lockScope

    property var locked: false
    onLockedChanged: {
        if (locked) {
            pauseMedia();
        }
    }

	readonly property bool mediaPlaying: Mpris.players.values.some(player => {
		return player.playbackState === MprisPlaybackState.Playing && player.canPause;
	});

	function pauseMedia() {
		Mpris.players.values.forEach(player => {
			if (player.playbackState === MprisPlaybackState.Playing && player.canPause) {
				player.playbackState = MprisPlaybackState.Paused;
			}
		});
	}

    // This stores all the information shared between the lock surfaces on each screen.
    LockContext {
        id: lockContext

        onUnlocked: {
            // Unlock the screen before exiting, or the compositor will display a
            // fallback lock you can't interact with.
            lockScope.locked = false;
        }
    }

    WlSessionLock {
        id: lock

        locked: lockScope.locked

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    GlobalShortcut {
        name: "lock-screen"
        onPressed: {
            lockScope.locked = true;
        }
        description: "Lock the screen, `hyprctl dispatch global quickshell:lock-screen` to lock from a command"
    }
}
