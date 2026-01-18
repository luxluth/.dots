import QtQuick
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

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateActivePlayer()
    }

    function cyclePlayer() {
        const list = Mpris.players.values;
        if (list.length <= 1)
            return;

        let idx = list.indexOf(root.activePlayer);
        if (idx === -1) {
            root.activePlayer = list[0];
        } else {
            root.activePlayer = list[(idx + 1) % list.length];
        }
    }

    function updateActivePlayer() {
        const list = Mpris.players.values;
        if (list.length === 0) {
            root.activePlayer = null;
            return;
        }

        // If current player is still valid and playing, keep it
        if (root.activePlayer && list.includes(root.activePlayer) && root.activePlayer.playbackState === MprisPlaybackState.Playing) {
            return;
        }

        // Try to find currently playing player
        const playing = list.find(p => p.playbackState === MprisPlaybackState.Playing);
        if (playing) {
            if (root.activePlayer !== playing) {
                root.activePlayer = playing;
            }
            return;
        }

        // If current active player is still valid (in the list), keep it
        if (root.activePlayer && list.includes(root.activePlayer)) {
            return;
        }

        // Fallback to the first player
        root.activePlayer = list[0];
    }
}
