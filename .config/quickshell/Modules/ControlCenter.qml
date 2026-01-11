import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io

import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray

import "../Assets/"
import "../Components/"

Rectangle {
    id: root
    width: 600
    height: 500
    color: colors.bg
    radius: 16
    border.color: colors.border
    border.width: 2

    // Animation properties
    transformOrigin: Item.TopRight
    scale: 0.9
    opacity: 0

    // Signal to notify parent when closing animation is done
    signal closed

    function close() {
        exitAnim.start();
    }

    function open() {
        enterAnim.start();
    }

    // Enter Animation
    ParallelAnimation {
        id: enterAnim
        running: true
        NumberAnimation {
            target: root
            property: "scale"
            from: 0.9
            to: 1.0
            duration: 200
            easing.type: Easing.OutBack
        }
        NumberAnimation {
            target: root
            property: "opacity"
            from: 0
            to: 1
            duration: 150
        }
    }

    // Exit Animation
    ParallelAnimation {
        id: exitAnim
        onFinished: root.closed()
        NumberAnimation {
            target: root
            property: "scale"
            from: 1.0
            to: 0.9
            duration: 150
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: root
            property: "opacity"
            from: 1
            to: 0
            duration: 100
        }
    }

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
                    onClicked: ctx.network.toggleWifi()
                    onArrowClicked: console.log("Open Network Settings")
                }
                StateButton {
                    title: "Bluetooth"
                    icon: !ctx.blt.adapter.enabled ? Icons.bluetoothOff : (ctx.blt.connected ? Icons.bluetoothConnected : Icons.bluetoothActive)
                    isActive: ctx.blt.adapter.enabled
                    details: ctx.blt.connected ? `${ctx.blt.connected.name} ${ctx.blt.connected.batteryAvailable ? (ctx.blt.connected.battery * 100).toString() + "%" : ""}` : "$ Not Paired"
                    onClicked: {
                        if (ctx.blt.adapter.enabled) {
                            for (const device of ctx.blt.devices) {
                                if (device.connected)
                                    device.disconnect();
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
                    onClicked: ctx.power.cycle()
                }
            }
        }

        // Placeholders for other sections
        // LEFT BOTTOM
        Rectangle {
            Layout.column: 0
            Layout.row: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth: parent.width * 0.45
            Layout.preferredHeight: parent.height * 0.6

            radius: 8
            color: "transparent"
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
            color: "transparent"
        }

        // RIGHT BOTTOM
        Rectangle {
            Layout.column: 1
            Layout.row: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "transparent"
        }
    }
}
