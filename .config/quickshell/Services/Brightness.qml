pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "../Components/"
import "../Assets/"

Item {
    id: root
    property real brightness: 0

    property bool shouldShowOsd: false
    property bool closing: false

    function setBrightness(v) {
        const percent = Math.round(v * 100);
        setProc.command = ["brightnessctl", "s", percent + "%"];
        setProc.running = true;
        brightness = v;
    }

    readonly property string path: "/sys/class/backlight/intel_backlight"
    property int maxBrightness: 96000

    Process {
        id: maxProc
        command: ["cat", `${root.path}/max_brightness`]
        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim());
                if (!isNaN(val) && val > 0) {
                    root.maxBrightness = val;
                    // console.log("max", root.maxBrightness);
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
                }
            }
        }
    }

    Process {
        id: setProc
    }

    Process {
        id: monitorProc
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
        running: true

        stdout: SplitParser {
            onRead: _ => brightProc.running = true
        }
    }

    Connections {
        target: root

        function onBrightnessChanged() {
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
                            iconSource: root.getBrightnessIcon()
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            Rectangle {
                                // Stretches to fill all left-over space
                                Layout.fillWidth: true

                                implicitHeight: 7
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

                                    implicitWidth: parent.width * (root.brightness)
                                    radius: parent.radius

                                    Behavior on implicitWidth {
                                        NumberAnimation {
                                            duration: 150
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
