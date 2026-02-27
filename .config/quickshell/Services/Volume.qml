pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

import "../Components/"
import "../Assets/"

Item {
    id: root

    property Pipewire pw: Pipewire
    property PwNode sink: pw.defaultAudioSink
    property PwNode source: pw.defaultAudioSource
    property bool defaultSinkMuted: sink.audio.muted
    property bool defaultSourceMuted: source?.audio.muted ?? true
    property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0

    property bool shouldShowOsd: false
    property bool closing: false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            root.shouldShowOsd = true;
            root.closing = false;
            hideTimer.restart();
        }

        function onMutedChanged() {
            root.shouldShowOsd = true;
            root.closing = false;
            hideTimer.restart();
        }
    }

    Connections {
        target: root.source?.audio

        function onMutedChanged() {
            if (root.parent && root.parent.osd) {
                root.parent.osd(root.defaultSourceMuted ? Icons.micOff : Icons.micOn, root.defaultSourceMuted ? "Microphone Muted" : "Microphone Unmuted", root.source?.description ?? "Default Source");
            }
        }
    }

    property bool _ready: false
    Component.onCompleted: _ready = true

    onSourceChanged: {
        if (_ready && source) {
            if (root.parent && root.parent.osd) {
                root.parent.osd(source.audio.muted ? Icons.micOff : Icons.micOn, "Microphone Changed", source.description ?? "Default Source");
            }
        }
    }

    function getDefaultSinkVolumeIcon() {
        const icons = ["", "", ""];

        return defaultSinkMuted ? "" : icons[Math.ceil(sink.audio.volume * 2)];
    }

    function getDefaultSinkVolumeSvg() {
        const icons = [Icons.volumeZero, Icons.volumeLow, Icons.volumeHigh];

        return defaultSinkMuted ? Icons.volumeMute : icons[Math.ceil(sink.audio.volume * 2)];
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.closing = true
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            anchors.bottom: true
            anchors.left: true
            margins.bottom: 20
            margins.left: 20
            exclusiveZone: 0

            WlrLayershell.namespace: "qs-osd"

            implicitWidth: 236
            implicitHeight: 70
            color: "transparent"

            // An empty click mask prevents the window from blocking mouse events.
            mask: Region {}

            Item {
                id: container
                anchors.centerIn: parent
                width: 216
                height: 50

                opacity: 0
                scale: 0.9
                transformOrigin: Item.Center

                ParallelAnimation {
                    id: enterAnim
                    running: true
                    NumberAnimation {
                        target: container
                        property: "scale"
                        from: 0.9
                        to: 1.0
                        duration: 200
                        easing.type: Easing.OutBack
                    }
                    NumberAnimation {
                        target: container
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 150
                    }
                }

                ParallelAnimation {
                    id: exitAnim
                    onFinished: root.shouldShowOsd = false
                    NumberAnimation {
                        target: container
                        property: "scale"
                        from: 1.0
                        to: 0.9
                        duration: 150
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: container
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 100
                    }
                }

                Connections {
                    target: root
                    function onClosingChanged() {
                        if (root.closing) {
                            exitAnim.start();
                        } else {
                            exitAnim.stop();
                            enterAnim.start();
                        }
                    }
                }

                Rectangle {
                    id: outer
                    anchors.fill: parent
                    radius: colors.radiusOsd
                    color: Qt.rgba(colors.bg.r, colors.bg.g, colors.bg.b, 0.9)
                    border.width: 1
                    border.color: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.1)

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 20
                            rightMargin: 20
                        }

                        CImage {
                            iconSource: root.getDefaultSinkVolumeSvg()
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            Rectangle {
                                // Stretches to fill all left-over space
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter

                                implicitHeight: 7
                                implicitWidth: 120
                                radius: colors.radiusBase
                                color: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.1)
                                border.width: 1
                                border.color: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.1)

                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                    }
                                    color: colors.fg

                                    implicitWidth: parent.width * (root.volume)
                                    radius: parent.radius

                                    Behavior on implicitWidth {
                                        NumberAnimation {
                                            duration: 50
                                        }
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: root.pw.defaultAudioSink.description || root.pw.defaultAudioSink.nickname
                                color: Qt.lighter(colors.fg, 2.1)
                                elide: Text.ElideRight

                                font.family: colors.fontFamily
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }
    }
}
