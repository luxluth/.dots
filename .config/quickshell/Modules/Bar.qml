pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

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
    implicitHeight: root.isHyprland ? 40 : 30
    color: "transparent"

    property alias ccBtn: batItem
    property bool hasWindows: root.context.compositor.hasWindows
    property bool isHovered: barMouseArea.containsMouse
    property bool isHyprland: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").toLowerCase() === "hyprland"
    property bool shouldShowFull: !isHyprland || hasWindows || isHovered || cc.visible
    property bool showFull: shouldShowFull

    onShouldShowFullChanged: {
        if (shouldShowFull) {
            cooloffTimer.stop();
            showFull = true;
        } else {
            cooloffTimer.restart();
        }
    }

    Timer {
        id: cooloffTimer
        interval: 2000 // 2 seconds cooloff before entering zen mode
        repeat: false
        onTriggered: showFull = false
    }

    MouseArea {
        id: barMouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: root.isHyprland ? 5 : 0
        anchors.leftMargin: root.isHyprland ? 10 : 0
        anchors.rightMargin: root.isHyprland ? 10 : 0
        anchors.bottomMargin: root.isHyprland ? 5 : 0
        color: root.isHyprland ? (showFull ? root.colors.transparentBg : "transparent") : root.colors.bg
        border.width: root.isHyprland ? (showFull ? 2 : 0) : 0
        border.color: root.colors.muted
        radius: root.isHyprland ? root.colors.radiusMedium : 0
        Behavior on color {
            ColorAnimation {
                duration: 250
            }
        }
        Behavior on border.width {
            NumberAnimation {
                duration: 250
            }
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: -4
            anchors.rightMargin: 4

            //// LEFT
            RowLayout {
                opacity: showFull ? 1.0 : 0.0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }
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

                            color: isActive ? root.colors.fg : root.colors.transparentFg
                            implicitWidth: isActive ? 30 : 20
                            height: 20
                            radius: root.colors.radiusExtraSmall

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
                        color: root.colors.transparentFg

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
                spacing: 10

                // Date
                Rectangle {
                    id: dateWrapper
                    color: "transparent"
                    radius: root.colors.radiusSmall
                    implicitWidth: date.contentWidth + 16
                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: 250
                        }
                    }
                    implicitHeight: 24

                    scale: dateMouse.containsPress ? 0.98 : 1.0
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
                        color: showFull ? root.colors.fg : root.colors.clockZen

                        font {
                            family: root.colors.fontFamily
                            pixelSize: 14
                            bold: true
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 250
                            }
                        }
                    }

                    MouseArea {
                        id: dateMouse
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: date.isTime = !date.isTime
                    }
                }
            }

            //// RIGHT
            RowLayout {
                id: rightSection
                opacity: (showFull || root.context.power.batteryLow) ? 1.0 : 0.0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                // Tray
                RowLayout {
                    id: trayRoot
                    visible: showFull

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

                        delegate: Rectangle {
                            id: trayItemWrapper

                            required property var modelData

                            Layout.preferredWidth: trayRoot.iconSize + 8
                            Layout.preferredHeight: trayRoot.iconSize + 8

                            radius: root.colors.radiusSmall
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
                    visible: showFull
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    color: "transparent"

                    Tip {
                        rootWindow: root
                        targetItem: idleItem
                        watcher: idleMouseArea
                        text: root.context.inhibitor.state.enabled ? "Activated" : "Deactivated"
                    }

                    CImage {
                        id: idleIcon
                        anchors.centerIn: parent
                        width: 14
                        height: 14
                        iconSource: root.context.inhibitor.state.enabled ? Icons.coffeeFilled : Icons.coffee
                        coloring: root.context.inhibitor.state.enabled ? root.colors.fg : root.colors.transparentFg
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
                    visible: showFull && (root.context.network.wifiConnected || root.context.network.ethernetConnected)
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
                    visible: showFull && root.context.blt.adapter.enabled
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: bltRow.implicitWidth + 10
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
                        text: root.context.blt.connected ? `${root.context.blt.connected.name} ${root.context.blt.connected.batteryAvailable ? (root.context.blt.connected.battery * 100).toFixed(0).toString() + "%" : ""}` : "Not Paired"
                    }
                }

                // Volume
                Item {
                    id: volItem
                    visible: showFull
                    implicitWidth: volRect.width
                    implicitHeight: volRect.height

                    Rectangle {
                        id: volRect
                        color: "#00000000"
                        implicitWidth: 24
                        implicitHeight: 24

                        CImage {
                            coloring: root.context.pw.defaultSinkMuted ? root.colors.transparentFg : root.colors.fg
                            anchors.centerIn: parent
                            width: 14
                            iconSource: root.context.pw.getDefaultSinkVolumeSvg()
                        }
                    }

                    MouseArea {
                        id: volumeArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    Tip {
                        rootWindow: root
                        targetItem: volItem
                        watcher: volumeArea
                        text: `${(root.context.pw.volume * 100).toFixed(0)}% ${root.context.pw.sink.description || root.context.pw.sink.nickname}`
                    }
                }

                // Battery
                Item {
                    id: batItem

                    implicitWidth: batRect.width
                    implicitHeight: batRect.height

                    ClippingRectangle {
                        id: batRect
                        implicitHeight: parent.parent.height - 4
                        implicitWidth: batText.implicitWidth + 20
                        antialiasing: true
                        radius: root.colors.radiusSmall
                        color: {
                            if (root.context.power.batteryLow)
                                return Qt.hsla(root.colors.red.hslHue, root.colors.red.hslSaturation, root.colors.red.hslLightness, .5);
                            return Qt.hsla(root.colors.fg.hslHue, root.colors.fg.hslSaturation, root.colors.fg.hslLightness, .5);
                        }

                        Rectangle {
                            id: ranged
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: parent.height
                            width: parent.width * root.context.power.battery.percentage
                            color: root.context.power.batteryLow ? root.colors.red : root.colors.fg
                        }
                    }

                    Text {
                        id: batText
                        anchors.centerIn: parent
                        text: root.context.power.batteryPercentage
                        color: root.colors.bg

                        font {
                            family: "Inter"
                            pixelSize: 13
                            bold: true
                        }
                    }

                    MouseArea {
                        id: batMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: batItem.clicked()
                    }

                    scale: batMouse.containsPress ? 0.90 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }

                    IpcHandler {
                        target: "cc"

                        function toggle(): void {
                            batItem.clicked();
                        }
                    }

                    signal clicked

                    Tip {
                        rootWindow: root
                        targetItem: batItem
                        watcher: batMouse
                        text: root.context.power.batteryAlternateText
                    }
                }
            }
        }
    }

    // Rectangle {
    //     id: bottomBorder
    //     anchors.bottom: parent.bottom
    //     anchors.left: parent.left
    //     anchors.right: parent.right
    //
    //     height: 0
    //     color: root.colors.border
    //
    //     z: 99
    // }
}
