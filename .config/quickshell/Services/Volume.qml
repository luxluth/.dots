pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

import "../Components/"
import "../Assets/"
import "../Core"

Item {
    id: root

    property Colors colors: null
    property Context context: null

    property Pipewire pw: Pipewire
    property PwNode sink: pw.defaultAudioSink
    property PwNode source: pw.defaultAudioSource
    property bool defaultSinkMuted: sink?.audio ? sink.audio.muted : false
    property bool defaultSourceMuted: source?.audio ? source.audio.muted : true
    property real volume: sink?.audio ? sink.audio.volume : 0

    property bool shouldShowOsd: false
    property bool closing: false

    PwObjectTracker {
        objects: [root.sink, root.source].filter(o => o !== null)
    }

    Connections {
        target: root.sink ? root.sink.audio : null
        ignoreUnknownSignals: true

        function onVolumesChanged() {
            if (!root._ready) return;
            root.shouldShowOsd = true;
            root.closing = false;
            hideTimer.restart();
        }

        function onMutedChanged() {
            if (!root._ready) return;
            root.shouldShowOsd = true;
            root.closing = false;
            hideTimer.restart();
        }
    }

    Connections {
        target: root.source ? root.source.audio : null
        ignoreUnknownSignals: true

        function onMutedChanged() {
            if (!root._ready) return;
            if (root.context && root.context.osd) {
                root.context.osd(root.defaultSourceMuted ? Icons.micOff : Icons.micOn, root.defaultSourceMuted ? "Microphone Muted" : "Microphone Unmuted", root.source?.description ?? "Default Source");
            }
        }
    }

    property bool _ready: false
    Component.onCompleted: {
        Qt.callLater(() => {
            root._ready = true;
        });
    }

    onSourceChanged: {
        if (_ready && source) {
            if (root.context && root.context.osd) {
                root.context.osd(source.audio?.muted ? Icons.micOff : Icons.micOn, "Microphone Changed", source.description ?? "Default Source");
            }
        }
    }

    function getDefaultSinkVolumeSvg() {
        if (root.defaultSinkMuted)
            return Icons.volumeMute;
        if (root.volume <= 0.01)
            return Icons.volumeZero;
        if (root.volume < 0.5)
            return Icons.volumeLow;
        return Icons.volumeHigh;
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.closing = true
    }

    LazyLoader {
        active: root.shouldShowOsd && root.colors !== null

        PanelWindow {
            screen: root.context?.window ? root.context.window.screen : (Quickshell.screens.length > 0 ? Quickshell.screens[0] : null)
            anchors.bottom: true
            anchors.left: true
            margins.bottom: 20
            margins.left: 20

            WlrLayershell.namespace: "qs-osd"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: -1

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
                    radius: root.colors.radiusOsd
                    color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.9)
                    border.width: 1
                    border.color: Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.1)

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 20
                            rightMargin: 20
                        }

                        CImage {
                            iconSource: root.getDefaultSinkVolumeSvg()
                            coloring: root.colors.fg
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            Rectangle {
                                // Stretches to fill all left-over space
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter

                                implicitHeight: 7
                                implicitWidth: 120
                                radius: root.colors.radiusBase
                                color: Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.1)
                                border.width: 1
                                border.color: Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.1)

                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                    }
                                    color: root.colors.fg

                                    implicitWidth: Math.min(parent.width, Math.max(0, parent.width * root.volume))
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
                                text: root.sink ? (root.sink.description || root.sink.nickname || "Default Output") : "Default Output"
                                color: Qt.lighter(root.colors.fg, 2.1)
                                elide: Text.ElideRight

                                font.family: root.colors.fontFamily
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }
    }
}
