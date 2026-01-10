import QtQuick
import Quickshell.Io

Item {
    property real brightness: 0

    function setBrightness(v) {
        const percent = Math.round(v * 100);
        setProc.command = ["brightnessctl", "s", percent + "%"];
        setProc.running = true;
        brightness = v;
    }

    Process {
        id: setProc
    }

    Process {
        id: brightProc

        command: ["brightnessctl", "-m"]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;

                const parts = data.split(",");
                for (let i = 0; i < parts.length; i++) {
                    if (parts[i].endsWith("%")) {
                        let val = parseFloat(parts[i]);
                        brightness = val / 100;
                        return;
                    }
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightProc.running = true
    }
}
