pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

import "../Components"
import "../Assets"
import "../Core"

PanelWindow {
    id: root

    required property Context context
    required property Colors colors
    required property PanelWindow cc

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: colors.bg

    property alias ccBtn: ccBtn

    Item {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 5

        //// LEFT
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 15

            // Workspaces
            RowLayout {
                Rectangle {
                    width: 5
                }

                Repeater {
                    model: root.context.compositor.workspaces

                    delegate: Rectangle {
                        id: workspaceItem

                        required property int index
                        required property var modelData

                        property var ws: modelData
                        property bool isActive: root.context.compositor.focusedWorkspace?.id === (ws.id)

                        color: isActive ? root.colors.fg : root.colors.muted
                        implicitWidth: isActive ? 30 : 20
                        height: 20
                        radius: 2

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        scale: workspaceMouse.containsPress ? 0.85 : 1.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                            }
                        }

                        Behavior on implicitWidth {
                            NumberAnimation {
                                duration: 100
                            }
                        }

                        MouseArea {
                            id: workspaceMouse
                            hoverEnabled: true
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.context.compositor.gotoWorkspace(workspaceItem.ws.id)
                            onWheel: wheel => {
                                const step = wheel.angleDelta.y / 120;
                                if (step !== 0)
                                    root.context.compositor.gotoWorkspaceStep(-step);
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                height: 16
                color: root.colors.muted
                opacity: 0.5
            }

            ColumnLayout {
                spacing: 0

                // Title
                Text {
                    text: root.context.compositor.focused[1]
                    color: root.colors.fg

                    font {
                        family: root.colors.fontFamily
                        pixelSize: 13
                        bold: true
                    }

                    Layout.maximumWidth: 600
                    elide: Text.ElideRight
                }

                // Class
                Text {
                    text: root.context.compositor.focused[0]
                    color: root.colors.muted

                    font {
                        family: root.colors.fontFamily
                        pixelSize: 11
                        bold: true
                    }
                    // May never occures
                    Layout.maximumWidth: 300
                    elide: Text.ElideRight
                }
            }
        }

        //// CENTER
        RowLayout {
            anchors.centerIn: parent
            // Date
            Rectangle {
                id: dateWrapper
                color: root.context.notificationPopupVisible ? root.colors.muted : "transparent"
                radius: 4
                implicitWidth: date.contentWidth + 16
                implicitHeight: 24

                scale: dateMouse.containsPress ? 0.95 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    id: date

                    property bool isTime: true

                    text: isTime ? root.context.time : root.context.date
                    anchors.centerIn: parent
                    color: root.colors.fg

                    font {
                        family: root.colors.fontFamily
                        pixelSize: 14
                        bold: true
                    }
                }

                MouseArea {
                    id: dateMouse
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: event => {
                        if (event.button === Qt.RightButton) {
                            date.isTime = !date.isTime;
                        } else {
                            root.context.toggleNotifications();
                        }
                    }
                }
            }
        }

        //// RIGHT
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            // Tray
            RowLayout {
                id: trayRoot

                property int iconSize: 16
                property var pinnedApps: []
                property var blacklist: []
                property bool hidePassive: false
                property var colors: root.colors

                property var visibleItems: {
                    var items = SystemTray.items.values || [];
                    return items.filter(item => {
                        if (blacklist.some(name => {
                            return item.id.toLowerCase().includes(name.toLowerCase());
                        }))
                            return false;

                        if (hidePassive && item.status === SystemTrayStatus.Passive)
                            return false;

                        return true;
                    });
                }

                spacing: 6

                Repeater {
                    model: trayRoot.visibleItems

                    Rectangle {
                        id: trayItemWrapper

                        required property var modelData

                        Layout.preferredWidth: trayRoot.iconSize + 8
                        Layout.preferredHeight: trayRoot.iconSize + 8

                        radius: 4
                        color: itemMouse.containsMouse ? root.colors.muted : "transparent"

                        Image {
                            id: trayIcon

                            anchors.centerIn: parent
                            width: trayRoot.iconSize
                            height: trayRoot.iconSize
                            source: trayItemWrapper.modelData.icon
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            visible: status === Image.Ready || status === Image.Loading
                        }

                        Text {
                            anchors.centerIn: parent
                            text: trayIcon.status === Image.Error ? "?" : ""
                            color: root.colors.muted
                            font.pixelSize: 10
                            visible: trayIcon.status === Image.Error
                        }

                        MouseArea {
                            id: itemMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            onClicked: mouse => {
                                const pos = trayItemWrapper.mapToGlobal(0, 0);

                                if (mouse.button === Qt.LeftButton) {
                                    trayItemWrapper.modelData.activate(pos.x, pos.y);
                                } else if (mouse.button === Qt.MiddleButton) {
                                    trayItemWrapper.modelData.secondaryActivate(pos.x, pos.y);
                                } else if (mouse.button === Qt.RightButton) {
                                    const menu = trayItemWrapper.modelData.menu;
                                    const hasMenu = trayItemWrapper.modelData.hasMenu;
                                    if (hasMenu && menu) {
                                        const relativePos = trayItemWrapper.mapToItem(root.contentItem, trayItemWrapper.x + trayItemWrapper.width, trayItemWrapper.y + trayItemWrapper.height);
                                        trayItemWrapper.modelData.display(root, Math.round(relativePos.x), Math.round(relativePos.y));
                                    }
                                }
                            }
                        }
                        Tip {
                            rootWindow: root
                            watcher: itemMouse
                            targetItem: trayItemWrapper
                            text: trayItemWrapper.modelData.tooltipTitle || trayItemWrapper.modelData.title || trayItemWrapper.modelData.id
                        }
                    }
                }
            }

            // Idle Inhibitor
            Rectangle {
                id: idleItem
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                color: "transparent"

                Tip {
                    rootWindow: root
                    targetItem: idleItem
                    watcher: idleMouseArea
                    text: root.context.inhibitor.state.enabled ? "Activated" : "Deactivated"
                }

                Text {
                    id: idleText

                    anchors.centerIn: parent
                    text: root.context.inhibitor.state.enabled ? "󰅶" : "󰛊"
                    color: root.colors.fg

                    font {
                        family: root.colors.fontFamily
                        pixelSize: 14
                        bold: true
                    }
                }

                scale: idleMouseArea.containsPress ? 0.85 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
                }

                MouseArea {
                    id: idleMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.context.inhibitor.state.enabled = !root.context.inhibitor.state.enabled
                }
            }

            // Network
            Rectangle {
                id: netItem
                visible: root.context.network.wifiConnected || root.context.network.ethernetConnected
                Layout.preferredHeight: 24
                Layout.preferredWidth: netRow.implicitWidth + 10
                color: "transparent"

                RowLayout {
                    id: netRow
                    anchors.centerIn: parent
                    spacing: 5

                    CImage {
                        width: 14
                        iconSource: {
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
                    }

                    Text {
                        text: root.context.network.ifaceName
                        color: root.colors.fg
                        font {
                            family: root.colors.fontFamily
                            pixelSize: 14
                            bold: true
                        }
                    }
                }

                MouseArea {
                    id: netMouse
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Tip {
                    rootWindow: root
                    targetItem: netItem
                    watcher: netMouse
                    text: {
                        if (root.context.network.ipv4 !== "")
                            return root.context.network.ipv4;
                        if (root.context.network.ipv6 !== "")
                            return root.context.network.ipv6;
                        return "...";
                    }
                }
            }

            // BLT
            Rectangle {
                id: bltItem
                Layout.preferredHeight: 24
                Layout.preferredWidth: bltRow.implicitWidth + 10

                visible: root.context.blt.adapter.enabled
                color: "transparent"

                RowLayout {
                    id: bltRow
                    anchors.centerIn: parent
                    spacing: 5

                    CImage {
                        iconSource: root.context.blt.connected ? Icons.bluetoothConnected : Icons.bluetoothActive
                        width: 14
                    }

                    Text {
                        text: root.context.blt.adapter.adapterId
                        color: root.colors.fg

                        font {
                            family: root.colors.fontFamily
                            pixelSize: 14
                            bold: true
                        }
                    }
                }

                MouseArea {
                    id: bltMouse
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Tip {
                    rootWindow: root
                    targetItem: bltItem
                    watcher: bltMouse
                    text: root.context.blt.connected ? `${root.context.blt.connected.name} ${root.context.blt.connected.batteryAvailable ? (root.context.blt.connected.battery * 100).toString() + "%" : ""}` : "Not Paired"
                }
            }

            // Volume
            Text {
                text: `${Math.floor(root.context.pw.sink.audio.volume * 100)}% ${root.context.pw.getDefaultSinkVolumeIcon()}`
                color: root.context.pw.defaultSinkMuted ? root.colors.muted : root.colors.fg

                font {
                    family: root.colors.fontFamily
                    pixelSize: 14
                    bold: true
                }
            }

            // Battery
            Rectangle {
                id: batItem
                height: parent.height

                Layout.preferredHeight: 24
                Layout.preferredWidth: batText.implicitWidth + 10
                radius: 4
                color: "transparent"

                MouseArea {
                    id: batMouse
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Text {
                    id: batText
                    anchors.centerIn: parent
                    text: root.context.power.batteryPercentage
                    color: root.context.power.batteryLow ? root.colors.red : root.colors.fg

                    Tip {
                        rootWindow: root
                        targetItem: batItem
                        watcher: batMouse
                        text: root.context.power.batteryAlternateText
                    }

                    font {
                        family: root.colors.fontFamily
                        pixelSize: 14
                        bold: true
                    }
                }
            }

            // Control Center Invoke
            Rectangle {
                id: ccBtn

                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 4
                color: ccHover.containsMouse || root.cc.visible ? root.colors.muted : "transparent"

                Text {
                    text: "󰤂"
                    color: root.colors.fg
                    anchors.centerIn: parent
                    font {
                        family: root.colors.fontFamily
                        pixelSize: 14
                        bold: true
                    }
                }

                scale: ccHover.containsPress ? 0.85 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
                }
                MouseArea {
                    id: ccHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ccBtn.clicked()
                }

                IpcHandler {
                    target: "cc"

                    function toggle(): void {
                        ccBtn.clicked();
                    }
                }

                IpcHandler {
                    target: "notif"

                    function toggle(): void {
                        root.context.toggleNotifications();
                    }
                }

                signal clicked
            }
        }
    }

    Rectangle {
        id: bottomBorder
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        height: 1
        color: root.colors.border

        z: 99
    }
}
