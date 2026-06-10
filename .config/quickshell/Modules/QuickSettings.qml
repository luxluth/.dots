import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth

import "../Assets/"
import "../Components/"
import "../Core"

Flickable {
    id: root

    required property Context context
    required property Colors colors
    property bool active: false

    onActiveChanged: {
        if (!active) {
            root.context.network.setScanning(false);
            if (root.context.blt.adapter) {
                root.context.blt.adapter.discovering = false;
            }
        } else {
            if (wifiBlock.expanded && root.context.network.wifiEnabled) {
                root.context.network.setScanning(true);
            }
            if (bluetoothBlock.expanded && (root.context.blt.adapter?.enabled ?? false)) {
                root.context.blt.adapter.discovering = true;
            }
        }
    }

    anchors.fill: parent
    contentHeight: contentColumn.height
    clip: true

    ColumnLayout {
        id: contentColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 8
        }
        height: Math.max(root.height - 16, implicitHeight)
        spacing: 10

        // Wi-Fi / Ethernet Block
        ColumnLayout {
            id: wifiBlock
            Layout.fillWidth: true
            spacing: 6

            property bool expanded: false

            onExpandedChanged: {
                if (!expanded) {
                    root.context.network.setScanning(false);
                }
            }

            Timer {
                id: wifiScanTimer
                interval: 5000
                running: wifiBlock.expanded && root.context.network.wifiEnabled && root.active
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    root.context.network.setScanning(false);
                    root.context.network.setScanning(true);
                }
            }

            StateButton {
                id: wifiButton
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
                isActive: root.context.network.ethernetConnected || (root.context.network.wifiEnabled && (root.context.network.wifiConnected || root.context.network.wifiConnecting))
                details: {
                    if (root.context.network.ethernetConnected)
                        return root.context.network.ipv4 || "Connected";
                    if (root.context.network.wifiConnecting)
                        return "Connecting...";
                    return root.context.network.wifiConnected ? root.context.network.wifiSsid : (root.context.network.wifiEnabled ? "Disconnected" : "Disabled");
                }
                expansion: !root.context.network.ethernetConnected
                isExpanded: parent.expanded
                onClicked: root.context.network.toggleWifi()
                onArrowClicked: parent.expanded = !parent.expanded
            }

            // Expanded Networks List
            Rectangle {
                id: networksArea
                Layout.fillWidth: true
                Layout.preferredHeight: parent.expanded && root.context.network.wifiEnabled ? Math.min(250, networksCol.implicitHeight + 16) : 0
                visible: Layout.preferredHeight > 0
                clip: true
                color: root.colors.contrast
                border.color: root.colors.border
                border.width: 1
                radius: root.colors.radiusSmall

                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                ColumnLayout {
                    id: networksCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 8
                    }
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Available Networks"
                            color: root.colors.fg
                            font {
                                family: root.colors.fontFamily
                                pixelSize: 12
                                bold: true
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "scanning..."
                            color: root.colors.transparentFg
                            font {
                                family: root.colors.fontFamily
                                pixelSize: 10
                            }
                            visible: root.context.network.scanning
                        }
                    }

                    Repeater {
                        model: root.context.network.availableNetworks

                        delegate: ColumnLayout {
                            id: networkDelegate
                            Layout.fillWidth: true
                            
                            property bool isNetworkVisible: networkDelegate.networkItem.signalStrength > 0 || networkDelegate.networkItem.connected
                            visible: isNetworkVisible
                            spacing: isNetworkVisible ? 4 : 0

                            property var networkItem: modelData
                            property bool isSelected: false

                            Item {
                                id: mainRowItem
                                Layout.fillWidth: true
                                implicitHeight: 32

                                Rectangle {
                                    id: hoverBg
                                    anchors.fill: parent
                                    color: itemMouseArea.containsMouse ? Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.08) : "transparent"
                                    radius: root.colors.radiusSmall
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 10

                                    Item {
                                        width: 16
                                        height: 16

                                        CImage {
                                            id: wifiIcon
                                            anchors.fill: parent
                                            iconSource: {
                                                const strength = networkDelegate.networkItem.signalStrength;
                                                if (strength > 0.75) return Icons.wifiHigh;
                                                if (strength > 0.50) return Icons.wifiMid;
                                                if (strength > 0.25) return Icons.wifiLow;
                                                return Icons.wifiZero;
                                            }
                                            visible: !syncIcon.visible
                                        }

                                        CImage {
                                            id: syncIcon
                                            anchors.fill: parent
                                            iconSource: Icons.loaderCircle
                                            visible: networkDelegate.networkItem.state === ConnectionState.Connecting || networkDelegate.networkItem.stateChanging
                                            RotationAnimation on rotation {
                                                loops: Animation.Infinite
                                                from: 0; to: 360; duration: 1200
                                                running: syncIcon.visible
                                            }
                                        }
                                    }

                                    Text {
                                        text: networkDelegate.networkItem.name || "Unknown SSID"
                                        color: networkDelegate.networkItem.connected ? root.colors.accent : root.colors.fg
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        font {
                                            family: root.colors.fontFamily
                                            pixelSize: 13
                                            bold: networkDelegate.networkItem.connected
                                        }
                                    }

                                    CImage {
                                        width: 14; height: 14
                                        iconSource: Icons.lock
                                        visible: networkDelegate.networkItem.security !== WifiSecurityType.Open
                                    }
                                }

                                MouseArea {
                                    id: itemMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (networkDelegate.networkItem.connected) {
                                            networkDelegate.networkItem.disconnect();
                                        } else if (networkDelegate.networkItem.known || networkDelegate.networkItem.security === WifiSecurityType.Open) {
                                            networkDelegate.networkItem.connect();
                                        } else {
                                            root.context.passwordPrompt("Enter password for " + (networkDelegate.networkItem.name || "network"), (password) => {
                                                networkDelegate.networkItem.connectWithPsk(password);
                                            });
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Bluetooth Block
        ColumnLayout {
            id: bluetoothBlock
            Layout.fillWidth: true
            spacing: 6

            property bool expanded: false

            onExpandedChanged: {
                if (!expanded && root.context.blt.adapter) {
                    root.context.blt.adapter.discovering = false;
                }
            }

            Timer {
                id: bluetoothScanTimer
                interval: 5000
                running: bluetoothBlock.expanded && (root.context.blt.adapter?.enabled ?? false) && root.active
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    if (root.context.blt.adapter) {
                        root.context.blt.adapter.discovering = false;
                        root.context.blt.adapter.discovering = true;
                    }
                }
            }

            StateButton {
                id: bluetoothButton
                title: "Bluetooth"
                icon: !(root.context.blt.adapter?.enabled ?? false) ? Icons.bluetoothOff : (root.context.blt.connected ? Icons.bluetoothConnected : Icons.bluetoothActive)
                isActive: root.context.blt.adapter?.enabled ?? false
                details: {
                    if (!(root.context.blt.adapter?.enabled ?? false))
                        return "Disabled";
                    if (root.context.blt.connected)
                        return `${root.context.blt.connected.name} ${root.context.blt.connected.batteryAvailable ? (root.context.blt.connected.battery * 100).toFixed(0).toString() + "%" : ""}`;
                    const connectingDev = root.context.blt.devices.find(d => d.state === BluetoothDeviceState.Connecting);
                    if (connectingDev)
                        return `Connecting to ${connectingDev.name || "device"}...`;
                    return "Not Connected";
                }
                expansion: root.context.blt.adapter?.enabled ?? false
                isExpanded: parent.expanded
                onClicked: {
                    if (root.context.blt.adapter.enabled) {
                        for (const device of root.context.blt.devices) {
                            if (device.connected)
                                device.disconnect();
                        }
                    }
                    root.context.blt.adapter.enabled = !root.context.blt.adapter.enabled;
                }
                onArrowClicked: {
                    parent.expanded = !parent.expanded;
                }
            }

            // Expanded Devices List
            Rectangle {
                id: bluetoothDevicesArea
                Layout.fillWidth: true
                Layout.preferredHeight: parent.expanded && (root.context.blt.adapter?.enabled ?? false) ? Math.min(250, bluetoothDevicesCol.implicitHeight + 16) : 0
                visible: Layout.preferredHeight > 0
                clip: true
                color: root.colors.contrast
                border.color: root.colors.border
                border.width: 1
                radius: root.colors.radiusSmall

                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                ColumnLayout {
                    id: bluetoothDevicesCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 8
                    }
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Bluetooth Devices"
                            color: root.colors.fg
                            font {
                                family: root.colors.fontFamily
                                pixelSize: 12
                                bold: true
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "scanning..."
                            color: root.colors.transparentFg
                            font {
                                family: root.colors.fontFamily
                                pixelSize: 10
                            }
                            visible: root.context.blt.adapter?.discovering ?? false
                        }
                    }

                    Repeater {
                        model: root.context.blt.devices

                        delegate: ColumnLayout {
                            id: deviceDelegate
                            Layout.fillWidth: true

                            property var deviceItem: modelData
                            property bool isDeviceVisible: deviceDelegate.deviceItem.name !== ""
                            visible: isDeviceVisible
                            spacing: isDeviceVisible ? 4 : 0

                            Item {
                                Layout.fillWidth: true
                                implicitHeight: 32

                                Rectangle {
                                    id: devHoverBg
                                    anchors.fill: parent
                                    color: devMouseArea.containsMouse ? Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.08) : "transparent"
                                    radius: root.colors.radiusSmall
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 10

                                    Item {
                                        width: 16
                                        height: 16

                                        CImage {
                                            id: devIcon
                                            anchors.fill: parent
                                            iconSource: {
                                                if (deviceDelegate.deviceItem.connected) return Icons.bluetoothConnected;
                                                return Icons.bluetoothActive;
                                            }
                                            visible: !devSyncIcon.visible
                                        }

                                        CImage {
                                            id: devSyncIcon
                                            anchors.fill: parent
                                            iconSource: Icons.loaderCircle
                                            visible: deviceDelegate.deviceItem.state === BluetoothDeviceState.Connecting || deviceDelegate.deviceItem.state === BluetoothDeviceState.Disconnecting
                                            RotationAnimation on rotation {
                                                loops: Animation.Infinite
                                                from: 0; to: 360; duration: 1200
                                                running: devSyncIcon.visible
                                            }
                                        }
                                    }

                                    Text {
                                        text: deviceDelegate.deviceItem.name || deviceDelegate.deviceItem.address || "Unknown Device"
                                        color: deviceDelegate.deviceItem.connected ? root.colors.accent : root.colors.fg
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        font {
                                            family: root.colors.fontFamily
                                            pixelSize: 13
                                            bold: deviceDelegate.deviceItem.connected
                                        }
                                    }

                                    Text {
                                        text: deviceDelegate.deviceItem.batteryAvailable ? `${(deviceDelegate.deviceItem.battery * 100).toFixed(0)}%` : ""
                                        color: root.colors.transparentFg
                                        font {
                                            family: root.colors.fontFamily
                                            pixelSize: 11
                                        }
                                        visible: deviceDelegate.deviceItem.batteryAvailable
                                    }
                                }

                                MouseArea {
                                    id: devMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (deviceDelegate.deviceItem.connected) {
                                            deviceDelegate.deviceItem.disconnect();
                                        } else {
                                            deviceDelegate.deviceItem.connect();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Power Profile Button
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
