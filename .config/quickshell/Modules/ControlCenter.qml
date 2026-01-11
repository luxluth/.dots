import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io

import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray // For system actions if available, or just shell commands

import "../Assets/"
import "../Components/"

// We wrap the whole thing in a component we can use inside a PopupWindow
Rectangle {
    id: root
    width: 600
    height: 500
    color: colors.bg
    radius: 16
    border.color: colors.border
    border.width: 2

    GridLayout {
        anchors.fill: parent
        anchors.margins: 8

        columns: 2
        columnSpacing: 8
        rowSpacing: 8

        // TOP LEFT: Connectivity
        Rectangle {
            Layout.column: 0
            Layout.row: 0

            // Sizing
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.45
            Layout.preferredHeight: parent.height * 0.6

            radius: 8

            border.color: colors.border
            border.width: 2
            color: colors.contrast

            FlexboxLayout {

                anchors.fill: parent
                anchors.margins: 8

                direction: FlexboxLayout.Column

                gap: 10
                alignItems: FlexboxLayout.Stretch
                justifyContent: FlexboxLayout.JustifySpaceAround

                StateButton {
                    title: ctx.network.ethernetConnected ? "Wired" : "Wi-Fi"
                    icon: {
                        if (ctx.network.ethernetConnected)
                            return Icons.ethernetPort;
                        if (!ctx.network.wifiEnabled)
                            return Icons.wifiOff;
                        if (!ctx.network.wifiConnected)
                            return Icons.wifiZero;

                        const sig = ctx.network.wifiSignal;
                        if (sig > 75)
                            return Icons.wifiHigh;
                        if (sig > 50)
                            return Icons.wifiMid;
                        if (sig > 25)
                            return Icons.wifiLow;
                        return Icons.wifiZero;
                    }
                    isActive: ctx.network.ethernetConnected || (ctx.network.wifiEnabled && ctx.network.wifiConnected)
                    details: {
                        if (ctx.network.ethernetConnected)
                            return ctx.network.ipv4 || "Connected";
                        return ctx.network.wifiConnected ? ctx.network.wifiSsid : (ctx.network.wifiEnabled ? "Disconnected" : "Disabled");
                    }
                    onClicked: {
                        ctx.network.toggleWifi();
                    }
                    onArrowClicked: {
                        // Logic to open Network Menu
                        console.log("Open Network Settings");
                    }
                }
                StateButton {
                    title: "Bluetooth"
                    icon: !ctx.blt.adapter.enabled ? Icons.bluetoothOff : (ctx.blt.connected ? Icons.bluetoothConnected : Icons.bluetoothActive)
                    isActive: ctx.blt.adapter.enabled
                    details: ctx.blt.connected ? `${ctx.blt.connected.name} ${ctx.blt.connected.batteryAvailable ? (ctx.blt.connected.battery * 100).toString() + "%" : ""}` : "$ Not Paired"

                    onClicked: () => {
                        if (ctx.blt.adapter.enabled) {
                            for (const device of ctx.blt.devices) {
                                if (device.connected) {
                                    device.disconnect();
                                }
                            }
                        }
                        ctx.blt.adapter.enabled = !ctx.blt.adapter.enabled;
                    }
                }
                StateButton {
                    title: "Power Profile"
                    icon: {
                        if (ctx.power.profile == 0)
                            return Icons.scale;
                        if (ctx.power.profile == 1)
                            return Icons.zap;
                        if (ctx.power.profile == 2)
                            return Icons.sproot;
                    }
                    expansion: false
                    isActive: ctx.power.profile > 0
                    details: ctx.power.profileToText(ctx.power.profile).replace("-", " ").toUpperCase()

                    onClicked: () => {
                        ctx.power.cycle();
                    }
                }
            }
        }

        // LEFT BOTTOM
        Rectangle {
            Layout.column: 0
            Layout.row: 1

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth: parent.width * 0.45
            Layout.preferredHeight: parent.height * 0.6

            radius: 8
            border.color: "transparent" // colors.border
            border.width: 2

            color: "transparent"

            // ColumnLayout {
            //     Layout.fillWidth: true
            //     spacing: 10
            // }
        }

        // RIGHT TOP
        Rectangle {
            Layout.column: 1
            Layout.row: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth: parent.width * 0.45
            Layout.preferredHeight: parent.height * 0.6

            radius: 8
            border.color: "transparent" // colors.border
            border.width: 2

            color: "transparent"

            // ColumnLayout {
            //     Layout.fillWidth: true
            //     spacing: 10
            // }
        }

        // RIGHT BOTTOM
        Rectangle {
            Layout.column: 1
            Layout.row: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: 8
            border.color: "transparent" // colors.border
            border.width: 2

            color: "transparent"

            // ColumnLayout {
            //     Layout.fillWidth: true
            //     spacing: 10
            // }
        }
    }
}
