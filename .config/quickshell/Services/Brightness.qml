pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "../Components/"
import "../Assets/"
import "../Core"

Item {
    id: root

    property Colors colors: null
    property Context context: null

    property real brightness: 0
    property bool shouldShowOsd: false
    property bool closing: false
    property bool _ready: false
    property real pendingBrightness: -1

    function setBrightness(v) {
        const percent = Math.max(1, Math.min(100, Math.round(v * 100)));
        brightness = percent / 100.0;
        pendingBrightness = percent;
        applyBrightness();
    }

    function applyBrightness() {
        if (pendingBrightness < 0 || setProc.running)
            return;
        const val = pendingBrightness;
        pendingBrightness = -1;
        setProc.command = ["brightnessctl", "s", val + "%"];
        setProc.running = true;
    }

    property string backlightDevice: ""
    readonly property string path: backlightDevice ? `/sys/class/backlight/${backlightDevice}` : ""
    property int maxBrightness: 96000

    Process {
        id: discoverProc
        command: ["sh", "-c", "ls /sys/class/backlight | head -n 1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const dev = data.trim();
                if (dev) {
                    root.backlightDevice = dev;
                    maxProc.running = true;
                    monitorProc.running = true;
                }
            }
        }
    }

    Process {
        id: maxProc
        running: false
        command: ["cat", `${root.path}/max_brightness`]
        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim());
                if (!isNaN(val) && val > 0) {
                    root.maxBrightness = val;
                    brightProc.running = true;
                }
            }
        }
    }

    Process {
        id: brightProc
        command: ["cat", `${root.path}/brightness`]
        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim());
                if (!isNaN(val)) {
                    brightness = val / root.maxBrightness;
                    if (!root._ready) {
                        Qt.callLater(() => {
                            root._ready = true;
                        });
                    }
                }
            }
        }
    }

    Process {
        id: setProc
        onExited: {
            if (pendingBrightness >= 0) {
                applyBrightness();
            }
        }
    }

    Process {
        id: monitorProc
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
        running: false

        stdout: SplitParser {
            onRead: _ => brightProc.running = true
        }
    }

    Connections {
        target: root

        function onBrightnessChanged() {
            if (!root._ready) return;
            root.shouldShowOsd = true;
            root.closing = false;
            hideTimer.restart();
        }
    }

    function getBrightnessIcon() {
        if (root.brightness < 0.33)
            return Icons.sunLow;
        if (root.brightness < 0.66)
            return Icons.sunMid;
        return Icons.sunHigh;
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
                            iconSource: root.getBrightnessIcon()
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

                                    implicitWidth: Math.min(parent.width, Math.max(0, parent.width * root.brightness))
                                    radius: parent.radius

                                    Behavior on implicitWidth {
                                        NumberAnimation {
                                            duration: 150
                                        }
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: `${Math.round(root.brightness * 100)}%`
                                color: Qt.lighter(root.colors.fg, 2.1)
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
