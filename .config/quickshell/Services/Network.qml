import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool wifiEnabled: false
    property bool wifiConnected: false
    property string wifiSsid: ""
    property int wifiSignal: 0
    property bool ethernetConnected: false
    property string ifaceName: ""
    property string ipv4: ""
    property string ipv6: ""

    function toggleWifi() {
        if (sock.connected) {
            sock.write(JSON.stringify({
                action: "toggle_wifi"
            }) + "\n");
        } else {
            console.warn("Network socket not connected, cannot toggle wifi");
        }
    }

    Process {
        id: daemon
        running: true
        command: ["/home/luxluth/.config/quickshell/tools/network-watcher/target/release/network-watcher"]
        onExited: (code, status) => {
            console.log("Network watcher exited with code " + code);
            restartTimer.start();
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: daemon.running = true
    }

    Socket {
        id: sock
        path: "/home/luxluth/.config/quickshell/.net.sock"

        connected: daemon.running

        parser: SplitParser {
            onRead: data => {
                const line = data.trim();
                if (line.length > 0) {
                    try {
                        const state = JSON.parse(line);
                        root.wifiEnabled = state.wifi_enabled;
                        root.wifiConnected = state.wifi_connected;
                        root.wifiSsid = state.wifi_ssid || "";
                        root.wifiSignal = state.wifi_signal;
                        root.ethernetConnected = state.ethernet_connected || false;
                        root.ifaceName = state.iface_name || "";
                        root.ipv4 = state.ipv4 || "";
                        root.ipv6 = state.ipv6 || "";
                    } catch (e) {
                        console.error("Failed to parse network state:", e, line);
                    }
                }
            }
        }

        onConnectedChanged: {
            if (!connected) {
                reconnectTimer.start();
            } else {
                reconnectTimer.stop();
            }
        }

        onError: error => {
            console.log("Socket error: " + error);
            connected = false;
        }
    }

    Timer {
        id: reconnectTimer
        interval: 2000
        repeat: true
        running: !sock.connected
        onTriggered: {
            sock.connected = true;
        }
    }
}
