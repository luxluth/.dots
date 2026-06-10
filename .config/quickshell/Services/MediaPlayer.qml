import QtQuick
import Quickshell.Services.Mpris

Item {
    id: root

    property var players: Mpris.players.values
    property MprisPlayer activePlayer: null
    property var previouslyPlaying: []

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00";
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        const s = Math.floor(seconds % 60);
        if (h > 0) {
            return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
        } else {
            return `${m}:${s.toString().padStart(2, '0')}`;
        }
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
            root.previouslyPlaying = [];
            return;
        }

        // Find currently playing players
        const playingPlayers = list.filter(p => p.playbackState === MprisPlaybackState.Playing);

        // Check if any player transitioned from paused/stopped to playing
        let newlyPlaying = null;
        for (const p of playingPlayers) {
            if (!root.previouslyPlaying.includes(p)) {
                newlyPlaying = p;
                break;
            }
        }

        // Update cache of playing players
        root.previouslyPlaying = playingPlayers;

        // If a player just started playing, switch to it immediately
        if (newlyPlaying) {
            root.activePlayer = newlyPlaying;
            return;
        }

        // If no new player started playing, and the current active player is still valid, keep it
        if (root.activePlayer && list.includes(root.activePlayer)) {
            return;
        }

        // Fallback to any currently playing player
        if (playingPlayers.length > 0) {
            root.activePlayer = playingPlayers[0];
            return;
        }

        // Fallback to the first player in the list
        root.activePlayer = list[0];
    }
}
