import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: vol

    property Pipewire pw: Pipewire
    property PwNode sink: pw.defaultAudioSink
    property bool defaultSinkMuted: sink.audio.muted

    PwObjectTracker {
        id: bdr
        objects: [vol.pw.defaultAudioSink]
    }

    property PwObjectTracker binder: bdr

    function getDefaultSinkVolumeIcon() {
        const icons = ["", "", ""];

        return defaultSinkMuted ? "" : icons[Math.ceil(sink.audio.volume * 2)];
    }
}
