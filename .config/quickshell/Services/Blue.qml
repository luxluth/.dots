import QtQuick
import Quickshell.Bluetooth
import "../Assets"

Item {
    id: root
    property list<BluetoothDevice> devices: Bluetooth.devices.values
    property var connected: null
    property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    signal deviceStatusChanged(string icon, string title, string subtitle)

    function updateConnectedDevice() {
        const list = Bluetooth.devices.values;
        root.connected = list.find(d => d.connected) || null;
    }

    Component.onCompleted: updateConnectedDevice()

    Instantiator {
        model: Bluetooth.devices

        onObjectAdded: root.updateConnectedDevice()
        onObjectRemoved: root.updateConnectedDevice()

        delegate: Connections {
            target: modelData
            ignoreUnknownSignals: true
            function onConnectedChanged() {
                root.updateConnectedDevice();

                const isConnected = target.connected;
                const title = isConnected ? "Bluetooth Connected" : "Bluetooth Disconnected";
                const name = target.name || target.address || "Unknown Device";
                const icon = isConnected ? Icons.bluetoothConnected : Icons.bluetoothOff;

                root.deviceStatusChanged(icon, title, name);
            }
        }
    }
}
