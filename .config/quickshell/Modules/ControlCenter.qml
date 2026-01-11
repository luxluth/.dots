import QtQuick
import QtQuick.Layouts

import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray

import "../Assets/"
import "../Components/"
import "../Core"

Rectangle {
    id: root

    required property Context context
    required property Colors colors

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
            border.color: root.colors.border
            border.width: 2
            color: root.colors.contrast

            FlexboxLayout {
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
                    icon: !root.context.blt.adapter.enabled ? Icons.bluetoothOff : (root.context.blt.connected ? Icons.bluetoothConnected : Icons.bluetoothActive)
                    isActive: root.context.blt.adapter.enabled
                    details: root.context.blt.connected ? `${root.context.blt.connected.name} ${root.context.blt.connected.batteryAvailable ? (root.context.blt.connected.battery * 100).toString() + "%" : ""}` : "$ Not Paired"
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
