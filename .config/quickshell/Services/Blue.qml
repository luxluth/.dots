import QtQuick
import Quickshell.Bluetooth
import "../Assets"

Item {
    id: root
    property list<BluetoothDevice> devices: Bluetooth.devices.values
    property var connected: devices.find(d => d.connected == true)
    property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    signal deviceStatusChanged(string icon, string title, string subtitle)

    Repeater {
        model: Bluetooth.devices

        Item {
            id: delegate
            required property var modelData
            property var device: modelData

            Connections {
                target: delegate.device
                function onConnectedChanged() {
                    const isConnected = delegate.device.connected;
                    const title = isConnected ? "Bluetooth Connected" : "Bluetooth Disconnected";
                    const name = delegate.device.name || delegate.device.address || "Unknown Device";
                    const icon = isConnected ? Icons.bluetoothConnected : Icons.bluetoothOff;

                    root.deviceStatusChanged(icon, title, name);
                }
            }
        }
    }
}
