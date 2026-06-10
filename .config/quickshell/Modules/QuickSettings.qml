import QtQuick
import QtQuick.Layouts
import Quickshell

import "../Assets/"
import "../Components/"
import "../Core"

FlexboxLayout {
    id: root

    required property Context context
    required property Colors colors

    anchors.fill: parent
    anchors.margins: 8
    direction: FlexboxLayout.Column
    gap: 10
    justifyContent: FlexboxLayout.JustifySpaceAround

    StateButton {
        title: root.context.network.ethernetConnected ? "Wired" : "Wi-Fi"
        icon: {
            if (root.context.network.ethernetConnected)
                return Icons.ethernetPort;
            if (!root.context.network.wifiEnabled)
                return Icons.wifiOff;
            if (!root.context.network.wifiConnected)
                return Icons.wifiZero;

            const sig = root.context.network.wifiSignal;
            if (sig > 75)
                return Icons.wifiHigh;
            if (sig > 50)
                return Icons.wifiMid;
            if (sig > 25)
                return Icons.wifiLow;
            return Icons.wifiZero;
        }
        isActive: root.context.network.ethernetConnected || (root.context.network.wifiEnabled && root.context.network.wifiConnected)
        details: {
            if (root.context.network.ethernetConnected)
                return root.context.network.ipv4 || "Connected";
            return root.context.network.wifiConnected ? root.context.network.wifiSsid : (root.context.network.wifiEnabled ? "Disconnected" : "Disabled");
        }
        onClicked: root.context.network.toggleWifi()
        onArrowClicked: console.log("Open Network Settings")
    }

    StateButton {
        title: "Bluetooth"
        icon: !(root.context.blt.adapter?.enabled ?? false) ? Icons.bluetoothOff : (root.context.blt.connected ? Icons.bluetoothConnected : Icons.bluetoothActive)
        isActive: root.context.blt.adapter?.enabled ?? false
        details: root.context.blt.connected ? `${root.context.blt.connected.name} ${root.context.blt.connected.batteryAvailable ? (root.context.blt.connected.battery * 100).toFixed(0).toString() + "%" : ""}` : "$ Not Paired"
        onClicked: {
            if (root.context.blt.adapter.enabled) {
                for (const device of root.context.blt.devices) {
                    if (device.connected)
                        device.disconnect();
                }
            }
            root.context.blt.adapter.enabled = !root.context.blt.adapter.enabled;
        }
    }

    StateButton {
        title: "Power Profile"
        icon: {
            if (root.context.power.profile == 0)
                return Icons.scale;
            if (root.context.power.profile == 1)
                return Icons.zap;
            if (root.context.power.profile == 2)
                return Icons.sproot;
        }
        expansion: false
        isActive: root.context.power.profile > 0
        details: root.context.power.profileToText(root.context.power.profile).replace("-", " ").toUpperCase()
        onClicked: root.context.power.cycle()
    }
}
