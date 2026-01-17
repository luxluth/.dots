pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.Notifications
import "../Services/"
import "../Assets/"

Item {
    id: root

    property QtObject window: null
    property string theme: "prefer-dark"
    property string time: Qt.formatTime(clock.date, "hh:mm AP")
    property string date: Qt.formatDate(clock.date, "dddd, d MMMM yyyy")
    property Compositor compositor: comp
    property Power power: pwr
    property Volume pw: pipewire
    property IInhibitor inhibitor: inhibit
    property Blue blt: blue
    property Network network: net
    property Brightness brightness: bright
    property SystemInfo system: sysInfo

    property bool airplaneMode: !network.wifiEnabled && !blt.adapter.enabled
    property var nsTracked: nServer.trackedNotifications.values

    onAirplaneModeChanged: {
        root.osd(Icons.plane, airplaneMode ? "Airplane Mode On" : "Airplane Mode Off", airplaneMode ? "Wireless communications disabled" : "Wireless communications enabled");
    }

    signal popup(string message, var actions, string defaultAction)
    signal osd(string icon, string title, string subtitle)
    signal notificationReceived(Notification notification)
    signal toggleNotifications

    property bool notificationPopupVisible: false
    property bool dnd: false

    SystemInfo {
        id: sysInfo
    }

    Brightness {
        id: bright
    }

    Network {
        id: net
    }

    Blue {
        id: blue
        onDeviceStatusChanged: (icon, title, subtitle) => root.osd(icon, title, subtitle)
    }

    IInhibitor {
        id: inhibit
        binding: root.window
        onStatusChanged: (icon, title, subtitle) => root.osd(icon, title, subtitle)
    }

    Volume {
        id: pipewire
    }

    Compositor {
        id: comp
    }

    Power {
        id: pwr
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    NotificationServer {
        id: nServer
        actionsSupported: true
        bodyMarkupSupported: true

        onNotification: n => {
            n.tracked = true;
            root.notificationReceived(n);
        }
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
}
