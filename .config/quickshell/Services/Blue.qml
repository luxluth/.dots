import QtQuick
import Quickshell.Bluetooth

Item {
    property list<BluetoothDevice> devices: Bluetooth.devices.values
    property var connected: devices.find(d => d.connected == true)
    property BluetoothAdapter adapter: Bluetooth.adapters.values[0]
}
