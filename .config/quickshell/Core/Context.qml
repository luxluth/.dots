pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick
import "../Services/" as Services

Item {
    id: root

    property QtObject window: null
    property string theme: "prefer-dark"
    property string time: Qt.formatTime(new Date(), "hh:mm AP")
    property string date: Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
    property Services.Compositor compositor: comp
    property Services.Power power: pwr
    property Services.Volume pw: pipewire
    property Services.IInhibitor inhibitor: inhibit
    property Services.Blue blt: blue
    property Services.Network network: net
    property Services.Brightness brightness: bright
    property Services.SystemInfo system: sysInfo

    Services.SystemInfo {
        id: sysInfo
    }

    Services.Brightness {
        id: bright
    }

    Services.Network {
        id: net
    }

    Services.Blue {
        id: blue
    }

    Services.IInhibitor {
        id: inhibit
        binding: root.window
    }

    Services.Volume {
        id: pipewire
    }

    Services.Compositor {
        id: comp
    }

    Services.Power {
        id: pwr
    }

    Process {
        id: colorScheme
        running: true
        command: ["fish", "-c", "dconf read /org/gnome/desktop/interface/color-scheme && dconf watch /org/gnome/desktop/interface/color-scheme"]
        stdout: SplitParser {
            onRead: data => {
                let d = data.trim();
                if (!d.startsWith("/") && d.length > 0) {
                    const scheme = d.replace("\'", "").replace("\'", "");
                    root.theme = scheme;
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: () => {
            root.time = Qt.formatTime(new Date(), "hh:mm AP");
            root.date = Qt.formatDate(new Date(), "dddd, d MMMM yyyy");
        }
    }
}
