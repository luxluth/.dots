import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: root

    property var players: Mpris.players.values
    property MprisPlayer activePlayer: null

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00";
        const m = Math.floor(seconds / 60);
        const s = Math.floor(seconds % 60);
        return `${m}:${s.toString().padStart(2, '0')}`;
    }

    // Auto-select active player
    // Logic: If activePlayer is null or stopped, try to find a playing one.
    // If multiple playing, keep current or pick first.
    // If none playing, pick first available.

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateActivePlayer()
    }

    function updateActivePlayer() {
        const list = Mpris.players.values;
        if (list.length === 0) {
            root.activePlayer = null;
            return;
        }

        // 1. Try to find currently playing player
        const playing = list.find(p => p.playbackState === MprisPlaybackState.Playing);
        if (playing) {
            if (root.activePlayer !== playing) {
                root.activePlayer = playing;
            }
            return;
        }

        // 2. If current active player is still valid (in the list), keep it
        if (root.activePlayer && list.includes(root.activePlayer)) {
            return;
        }

        // 3. Fallback to the first player
        root.activePlayer = list[0];
    }
}
