pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell.Networking

Item {
    id: root

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

    // NOTE: Quickshell.Networking does not strictly provide IP addresses on devices yet.
    // 'address' property is usually the MAC address. Mapping it here for now.
    property string ipv4: {
        if (wifiConnected && _wifiDevice)
            return _wifiDevice.address;
        if (ethernetConnected && _ethernetDevice)
            return _ethernetDevice.address;
        return "";
    }
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

    Instantiator {
        active: root._wifiDevice !== null
        model: root._wifiDevice ? root._wifiDevice.networks : null
        delegate: QtObject {
            id: ntwrk
            required property var modelData
            property var network: modelData

            property Connections conn: Connections {
                target: ntwrk.network
                function onConnectedChanged() {
                    if (ntwrk.network.connected)
                        root._currentWifiNetwork = ntwrk.network;
                    else if (root._currentWifiNetwork === ntwrk.network)
                        root._currentWifiNetwork = null;
                }
            }

            Component.onCompleted: {
                if (network.connected)
                    root._currentWifiNetwork = network;
            }
        }
    }
}
