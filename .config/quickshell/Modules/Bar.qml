pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

import "../Components"
import "../Assets"

PanelWindow {
    id: root

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
                    model: ctx.compositor.workspaces

                    delegate: Rectangle {
                        id: workspaceItem

                        width: 20
                        height: 20

                        required property int index
                        required property var modelData

                        property var ws: modelData
                        property bool isActive: ctx.compositor.focusedWorkspace?.id === (ws.id)

                        color: isActive ? colors.fg : colors.muted

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ctx.compositor.gotoWorkspace(ws.id)
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onWheel: wheel => {
                        const step = wheel.angleDelta.y / 120;
                        if (step !== 0)
                            ctx.compositor.gotoWorkspaceStep(-step);
                    }
                }
            }

            Rectangle {
                width: 1
                height: 16
                color: colors.muted
                opacity: 0.5
            }

            ColumnLayout {
                spacing: 0

                // Title
                Text {
                    text: ctx.compositor.focused[1]
                    color: colors.fg

                    font {
                        family: colors.fontFamily
                        pixelSize: 13
                        bold: true
                    }

                    Layout.maximumWidth: 600
                    elide: Text.ElideRight
                }

                // Class
                Text {
                    text: ctx.compositor.focused[0]
                    color: colors.muted

                    font {
                        family: colors.fontFamily
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
            Text {
                id: date

                property bool isTime: true

                text: isTime ? ctx.time : ctx.date
                color: colors.fg

                font {
                    family: colors.fontFamily
                    pixelSize: 14
                    bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: date.isTime = !date.isTime
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
                property var colors: null

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
                        color: itemMouse.containsMouse ? colors.muted : "transparent"

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
                            color: colors.muted
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
                    text: ctx.inhibitor.state.enabled ? "Activated" : "Deactivated"
                }

                Text {
                    id: idleText

                    anchors.centerIn: parent
                    text: ctx.inhibitor.state.enabled ? "󰅶" : "󰛊"
                    color: colors.fg

                    font {
                        family: colors.fontFamily
                        pixelSize: 14
                        bold: true
                    }
                }

                MouseArea {
                    id: idleMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ctx.inhibitor.state.enabled = !ctx.inhibitor.state.enabled
                }
            }

            // Network
            Rectangle {
                id: netItem
                visible: ctx.network.wifiConnected || ctx.network.ethernetConnected
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
                    }

                    Text {
                        text: ctx.network.ifaceName
                        color: colors.fg
                        font {
                            family: colors.fontFamily
                            pixelSize: 12
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
                        if (ctx.network.ipv4 !== "")
                            return ctx.network.ipv4;
                        if (ctx.network.ipv6 !== "")
                            return ctx.network.ipv6;
                        return "...";
                    }
                }
            }

            // BLT
            Rectangle {
                id: bltItem
                Layout.preferredHeight: 24
                Layout.preferredWidth: bltRow.implicitWidth + 10

                visible: ctx.blt.adapter.enabled
                color: "transparent"

                RowLayout {
                    id: bltRow
                    anchors.centerIn: parent
                    spacing: 5

                    CImage {
                        iconSource: ctx.blt.connected ? Icons.bluetoothConnected : Icons.bluetoothActive
                        width: 14
                    }

                    Text {
                        text: ctx.blt.adapter.adapterId
                        color: colors.fg

                        font {
                            family: colors.fontFamily
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
                    text: ctx.blt.connected ? `${ctx.blt.connected.name} ${ctx.blt.connected.batteryAvailable ? (ctx.blt.connected.battery * 100).toString() + "%" : ""}` : "Not Paired"
                }
            }

            // Volume
            Text {
                text: `${Math.floor(ctx.pw.sink.audio.volume * 100)}% ${ctx.pw.getDefaultSinkVolumeIcon()}`
                color: ctx.pw.defaultSinkMuted ? colors.muted : colors.fg

                font {
                    family: colors.fontFamily
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
                    text: ctx.power.batteryPercentage
                    color: ctx.power.batteryLow ? colors.red : colors.fg

                    Tip {
                        rootWindow: root
                        targetItem: batItem
                        watcher: batMouse
                        text: ctx.power.batteryAlternateText
                    }

                    font {
                        family: colors.fontFamily
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
                color: ccHover.containsMouse || dashboardWindow.visible ? colors.muted : "transparent"

                Text {
                    text: "󰤂"
                    color: colors.fg
                    anchors.centerIn: parent
                    font {
                        family: colors.fontFamily
                        pixelSize: 14
                        bold: true
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

                    function toogle(): void {
                        ccBtn.clicked();
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
        color: colors.border

        z: 99
    }
}
