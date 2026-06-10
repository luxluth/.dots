pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell.Networking
import Quickshell.Io

Item {
    id: root

    signal connectionFailed(string name, string reasonStr)

    property bool wifiEnabled: Networking.wifiEnabled
    property bool wifiConnected: _wifiDevice ? _wifiDevice.connected : false
    property string wifiSsid: _currentWifiNetwork ? _currentWifiNetwork.name : ""
    property int wifiSignal: 0
    property bool ethernetConnected: _ethernetDevice ? _ethernetDevice.connected : false

    function updateWifiSignal() {
        if (_currentWifiNetwork) {
            root.wifiSignal = _currentWifiNetwork.signalStrength * 100;
        } else {
            root.wifiSignal = 0;
        }
    }

    on_CurrentWifiNetworkChanged: updateWifiSignal()

    Connections {
        target: root._currentWifiNetwork
        function onSignalStrengthChanged() {
            root.updateWifiSignal();
        }
    }

    property string ifaceName: {
        if (wifiConnected && _wifiDevice)
            return _wifiDevice.name;
        if (ethernetConnected && _ethernetDevice)
            return _ethernetDevice.name;
        return "";
    }

    property string localIp: ""

    onIfaceNameChanged: updateIpAddress()
    onWifiConnectedChanged: updateIpAddress()
    onEthernetConnectedChanged: updateIpAddress()

    function updateIpAddress() {
        if (root.ifaceName === "") {
            root.localIp = "";
            return;
        }
        ipProc.command = ["sh", "-c", "ip -o -4 addr show dev " + root.ifaceName + " | awk '{print $4}' | cut -d/ -f1"];
        ipProc.running = true;
    }

    Process {
        id: ipProc
        running: false
        stdout: SplitParser {
            onRead: data => {
                root.localIp = data.trim();
            }
        }
    }

    property string ipv4: localIp
    property string ipv6: ""

    property var availableNetworks: _wifiDevice ? _wifiDevice.networks : null
    property bool scanning: _wifiDevice ? _wifiDevice.scannerEnabled : false

    function setScanning(enabled) {
        if (_wifiDevice) {
            _wifiDevice.scannerEnabled = enabled;
        }
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    onWifiEnabledChanged: {
        if (Networking.wifiEnabled !== wifiEnabled) {
            Networking.wifiEnabled = wifiEnabled;
        }
    }

    Connections {
        target: Networking
        function onWifiEnabledChanged() {
            root.wifiEnabled = Networking.wifiEnabled;
        }
    }

    property var _wifiDevices: []
    property var _wiredDevices: []
    property var _wifiDevice: _wifiDevices.length > 0 ? _wifiDevices[0] : null
    property var _ethernetDevice: _wiredDevices.length > 0 ? _wiredDevices[0] : null

    Instantiator {
        model: Networking.devices
        delegate: QtObject {
            required property var modelData

            Component.onCompleted: {
                let dev = modelData;
                if (dev.type === DeviceType.Wifi) {
                    root._wifiDevices = root._wifiDevices.concat([dev]);
                } else {
                    root._wiredDevices = root._wiredDevices.concat([dev]);
                }
            }

            Component.onDestruction: {
                let dev = modelData;
                root._wifiDevices = root._wifiDevices.filter(d => d !== dev);
                root._wiredDevices = root._wiredDevices.filter(d => d !== dev);
            }
        }
    }

    property var _currentWifiNetwork: null

    property bool wifiConnecting: false

    function updateConnectingStatus() {
        if (!root._wifiDevice) {
            root.wifiConnecting = false;
            return;
        }
        const list = root._wifiDevice.networks.values;
        root.wifiConnecting = list.some(n => n.state === ConnectionState.Connecting || n.stateChanging);
    }

    Instantiator {
        active: root._wifiDevice !== null
        model: root._wifiDevice ? root._wifiDevice.networks : null
        delegate: QtObject {
            id: ntwrk
            required property var modelData
            property var network: modelData

            property Connections conn: Connections {
                target: ntwrk.network
                ignoreUnknownSignals: true
                function onConnectedChanged() {
                    if (ntwrk.network.connected)
                        root._currentWifiNetwork = ntwrk.network;
                    else if (root._currentWifiNetwork === ntwrk.network)
                        root._currentWifiNetwork = null;
                }
                function onStateChanged() {
                    root.updateConnectingStatus();
                }
                function onStateChangingChanged() {
                    root.updateConnectingStatus();
                }
                function onConnectionFailed(reason) {
                    root.connectionFailed(ntwrk.network.name || "network", ConnectionFailReason.toString(reason));
                }
            }

            Component.onCompleted: {
                if (network.connected)
                    root._currentWifiNetwork = network;
                root.updateConnectingStatus();
            }

            Component.onDestruction: {
                Qt.callLater(root.updateConnectingStatus);
            }
        }
    }
}
