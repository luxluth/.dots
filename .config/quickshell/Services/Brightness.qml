import QtQuick
import Quickshell.Io

Item {
    id: root
    property real brightness: 0

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
                    console.log("max", root.maxBrightness);
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
}
