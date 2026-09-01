import QtQuick
import Quickshell.Io
import "../Assets"

Item {
    id: root

    signal osd(string icon, string title, string subtitle)

    Process {
        id: udevListener
        running: true
        command: [Qt.resolvedUrl("../scripts/udev_listener.py")]

        stdout: SplitParser {
            onRead: data => {
                console.log(data);
                const line = data.trim();
                if (!line)
                    return;
                try {
                    const obj = JSON.parse(line);
                    if (obj && obj.title) {
                        const iconMap = {
                            "zap": Icons.zap,
                            "hardDrive": Icons.hardDrive,
                            "gamepad": Icons.gamepad,
                            "keyboard": Icons.keyboard,
                            "mouse": Icons.mouse,
                            "plug": Icons.plug,
                            "usb": Icons.usb
                        };
                        const iconUrl = iconMap[obj.icon] || Icons.usb;
                        root.osd(iconUrl, obj.title, obj.subtitle || "");
                    }
                } catch (e) {
                    console.error("[Peripherals] Failed to parse udev output:", e, line);
                }
            }
        }
    }
}
