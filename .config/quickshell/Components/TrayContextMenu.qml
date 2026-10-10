import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland

import "../Assets"
import "../Core"

PanelWindow {
    id: root

    required property Colors colors

    property var menuHandle: null
    property var activeHandle: null
    property var activeSubmenuItem: null
    property string appTitle: ""
    property string appIcon: ""
    property real menuX: 0
    property real menuY: 0
    property real submenuX: 0
    property real submenuY: 0
    property bool isOpen: false

    function open(handle, iconX, iconBottomY, iconWidth, title, icon) {
        if (!handle) return;
        closeTimer.stop();
        activeHandle = handle;
        activeSubmenuItem = null;
        appTitle = title || "";
        appIcon = icon || "";

        // Re-bind to ensure fresh DBusMenu ref and trigger GetLayout
        opener.menu = null;
        menuHandle = handle;
        opener.menu = handle;

        try {
            if (handle.menu && handle.menu().updateLayout) {
                handle.menu().updateLayout();
            }
        } catch (e) {}

        const screenW = root.screen ? root.screen.width : (root.width > 0 ? root.width : 1920);
        const screenH = root.screen ? root.screen.height : (root.height > 0 ? root.height : 1080);
        const screenOriginX = root.screen ? root.screen.x : 0;
        const screenOriginY = root.screen ? root.screen.y : 0;

        const localIconX = iconX - screenOriginX;
        const localIconY = iconBottomY - screenOriginY;
        const widthVal = iconWidth || 24;

        const menuWidth = 240;
        let targetX = (localIconX + (widthVal / 2)) - (menuWidth / 2);
        targetX = Math.max(8, Math.min(targetX, screenW - menuWidth - 8));

        let targetY = Math.max(8, localIconY);
        targetY = Math.min(targetY, screenH - 120);

        menuX = targetX;
        menuY = targetY;

        submenuCloseTimer.stop();
        root.visible = true;
        isOpen = true;
    }

    function close() {
        isOpen = false;
        activeHandle = null;
        activeSubmenuItem = null;
        closeTimer.restart();
    }

    function showSubmenu(itemData, itemRowY) {
        submenuCloseTimer.stop();
        activeSubmenuItem = itemData;

        const screenW = root.screen ? root.screen.width : (root.width > 0 ? root.width : 1920);
        const screenH = root.screen ? root.screen.height : (root.height > 0 ? root.height : 1080);

        const subWidth = 220;
        // 2px overlap to eliminate dead gap when crossing
        if (wrapper.x + wrapper.width + subWidth - 2 <= screenW) {
            submenuX = wrapper.x + wrapper.width - 2;
        } else {
            submenuX = Math.max(8, wrapper.x - subWidth + 2);
        }

        let subY = wrapper.y + 8 - (menuFlickable ? menuFlickable.contentY : 0) + itemRowY - 4;
        subY = Math.max(8, Math.min(subY, screenH - 120));
        submenuY = subY;
    }

    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "qs-tray-menu"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Timer {
        id: closeTimer
        interval: 160
        repeat: false
        onTriggered: {
            root.visible = false;
            root.menuHandle = null;
            root.activeHandle = null;
            root.activeSubmenuItem = null;
            root.appTitle = "";
            root.appIcon = "";
        }
    }

    Timer {
        id: submenuCloseTimer
        interval: 350
        repeat: false
        onTriggered: {
            if (!submenuHover.hovered) {
                root.activeSubmenuItem = null;
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: root.close()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: root.close()
    }

    // Main Menu Card
    Item {
        id: wrapper

        readonly property real screenH: root.screen ? root.screen.height : (root.width > 0 ? root.height : 1080)
        readonly property real safeMaxHeight: Math.max(60, screenH - root.menuY - 16)

        x: root.menuX
        y: root.menuY
        width: 240
        height: Math.min(menuColumn.implicitHeight + 16, safeMaxHeight)

        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.96
        transformOrigin: Item.Top

        transform: Translate {
            y: root.isOpen ? 0 : -8
            Behavior on y {
                NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 0.8 }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 0.8 }
        }
        Behavior on height {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: menuBg
            anchors.fill: parent
            color: root.colors.transparentBg
            radius: root.colors.radiusMedium
            border.color: root.colors.muted
            border.width: 2
            clip: true

            QsMenuOpener {
                id: opener
                menu: root.menuHandle
            }

            Flickable {
                id: menuFlickable
                anchors.fill: parent
                anchors.margins: 8
                contentWidth: width
                contentHeight: menuColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                Column {
                    id: menuColumn
                    width: parent.width
                    spacing: 2

                    // App Identity Header Pill
                    Item {
                        id: appHeader
                        visible: root.appTitle !== ""
                        width: menuColumn.width
                        height: visible ? 28 : 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Image {
                                visible: root.appIcon !== "" && status !== Image.Error
                                source: root.appIcon
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                fillMode: Image.PreserveAspectFit
                                sourceSize.width: 16
                                sourceSize.height: 16

                                readonly property bool isSymbolic: {
                                    const src = (root.appIcon || "").toLowerCase();
                                    return src.includes("symbolic") || src.includes("fcitx") || src.includes("keyboard");
                                }
                                layer.enabled: isSymbolic
                                layer.effect: ColorOverlay {
                                    color: root.colors.accent
                                }
                            }

                            Text {
                                text: root.appTitle
                                color: root.colors.accent
                                font.pixelSize: 11
                                font.bold: true
                                font.family: root.colors.fontFamily
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                                opacity: 0.95
                            }
                        }
                    }

                    Rectangle {
                        visible: root.appTitle !== ""
                        width: menuColumn.width - 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: visible ? 1 : 0
                        color: root.colors.muted
                        opacity: 0.35
                    }

                    Repeater {
                        model: opener.children

                        delegate: Item {
                            id: menuItem
                            required property var modelData

                            readonly property bool isSeparator: modelData.isSeparator
                            readonly property bool hasChildren: modelData.hasChildren
                            readonly property bool isEnabled: modelData.enabled !== false
                            readonly property int buttonType: modelData.buttonType !== undefined ? modelData.buttonType : 0
                            readonly property int checkState: modelData.checkState !== undefined ? modelData.checkState : 0
                            readonly property bool isSubmenuActive: root.activeSubmenuItem === modelData
                            readonly property bool isHovered: itemMouse.containsMouse || isSubmenuActive
                            readonly property bool isDestructive: {
                                const txt = (modelData.text || "").toLowerCase();
                                return txt.includes("quit") || txt.includes("exit") || txt.includes("close") || txt.includes("remove") || txt.includes("disconnect");
                            }

                            width: menuColumn.width
                            height: isSeparator ? 9 : 32
                            visible: modelData.text !== "" || isSeparator

                            Rectangle {
                                visible: menuItem.isSeparator
                                anchors.centerIn: parent
                                width: parent.width - 8
                                height: 1
                                color: root.colors.muted
                                opacity: 0.4
                            }

                            Rectangle {
                                visible: !menuItem.isSeparator
                                anchors.fill: parent
                                radius: root.colors.radiusSmall
                                color: menuItem.isHovered && menuItem.isEnabled
                                    ? (menuItem.isDestructive
                                        ? Qt.rgba(root.colors.red.r, root.colors.red.g, root.colors.red.b, 0.16)
                                        : Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.16))
                                    : "transparent"

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }

                            Rectangle {
                                visible: !menuItem.isSeparator && menuItem.isHovered && menuItem.isEnabled
                                width: 3
                                height: 16
                                radius: root.colors.radiusExtraSmall
                                color: menuItem.isDestructive ? root.colors.red : root.colors.accent
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            RowLayout {
                                visible: !menuItem.isSeparator
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8
                                opacity: menuItem.isEnabled ? 1.0 : 0.4

                                // Fixed 18px Gutter for aligned reading column
                                Item {
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                    Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        anchors.centerIn: parent
                                        visible: menuItem.buttonType === 1
                                        width: 14
                                        height: 14
                                        radius: root.colors.radiusExtraSmall
                                        border.color: menuItem.checkState === Qt.Checked ? (menuItem.isDestructive ? root.colors.red : root.colors.accent) : root.colors.muted
                                        border.width: 1.5
                                        color: menuItem.checkState === Qt.Checked ? (menuItem.isDestructive ? root.colors.red : root.colors.accent) : "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            visible: menuItem.checkState === Qt.Checked
                                            text: "✓"
                                            color: root.colors.contrast
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }

                                    Rectangle {
                                        anchors.centerIn: parent
                                        visible: menuItem.buttonType === 2
                                        width: 14
                                        height: 14
                                        radius: 7
                                        border.color: menuItem.checkState === Qt.Checked ? (menuItem.isDestructive ? root.colors.red : root.colors.accent) : root.colors.muted
                                        border.width: 1.5
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            visible: menuItem.checkState === Qt.Checked
                                            width: 6
                                            height: 6
                                            radius: 3
                                            color: menuItem.isDestructive ? root.colors.red : root.colors.accent
                                        }
                                    }

                                    Image {
                                        id: itemIcon
                                        anchors.centerIn: parent
                                        visible: menuItem.buttonType === 0 && modelData.icon !== undefined && modelData.icon !== "" && status !== Image.Error
                                        width: 16
                                        height: 16
                                        source: modelData.icon || ""
                                        fillMode: Image.PreserveAspectFit
                                        sourceSize.width: 16
                                        sourceSize.height: 16

                                        readonly property bool isSymbolic: {
                                            const src = (modelData.icon || "").toLowerCase();
                                            return src.includes("symbolic") || !src.endsWith(".png");
                                        }

                                        layer.enabled: isSymbolic
                                        layer.effect: ColorOverlay {
                                            color: menuItem.isHovered ? (menuItem.isDestructive ? root.colors.red : root.colors.accent) : root.colors.fg
                                        }
                                    }
                                }

                                Text {
                                    text: (modelData.text || "").replace(/_([a-zA-Z0-9])/g, "$1")
                                    color: menuItem.isHovered && menuItem.isEnabled
                                        ? (menuItem.isDestructive ? root.colors.red : root.colors.fg)
                                        : Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.9)
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                    font.family: root.colors.fontFamily
                                    font.weight: Font.Medium
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Item {
                                    visible: menuItem.hasChildren
                                    Layout.preferredWidth: 14
                                    Layout.preferredHeight: 14
                                    Layout.alignment: Qt.AlignVCenter

                                    Image {
                                        anchors.centerIn: parent
                                        anchors.horizontalCenterOffset: menuItem.isHovered ? 2 : 0
                                        source: Icons.chevronRight
                                        width: 12
                                        height: 12
                                        fillMode: Image.PreserveAspectFit
                                        layer.enabled: true
                                        layer.effect: ColorOverlay {
                                            color: menuItem.isHovered ? root.colors.accent : Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.5)
                                        }

                                        Behavior on anchors.horizontalCenterOffset {
                                            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: menuItem.isEnabled && !menuItem.isSeparator
                                cursorShape: menuItem.isEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                                onEntered: {
                                    if (menuItem.hasChildren) {
                                        root.showSubmenu(modelData, menuItem.y);
                                    } else {
                                        submenuCloseTimer.restart();
                                    }
                                }

                                onClicked: {
                                    if (!menuItem.isEnabled || menuItem.isSeparator) return;

                                    if (menuItem.hasChildren) {
                                        root.showSubmenu(modelData, menuItem.y);
                                    } else {
                                        modelData.triggered();
                                        root.close();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Submenu Flyout Card
    Item {
        id: submenuWrapper
        z: 10

        readonly property real screenH: root.screen ? root.screen.height : (root.width > 0 ? root.height : 1080)
        readonly property real safeMaxHeight: Math.max(60, screenH - root.submenuY - 16)

        visible: root.activeSubmenuItem !== null
        x: root.submenuX
        y: root.submenuY
        width: 220
        height: Math.min(submenuColumn.implicitHeight + 16, safeMaxHeight)

        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.96
        transformOrigin: Item.TopLeft

        transform: Translate {
            y: root.activeSubmenuItem !== null ? 0 : -6
            Behavior on y {
                NumberAnimation { duration: 140; easing.type: Easing.OutBack; easing.overshoot: 0.7 }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 140; easing.type: Easing.OutBack; easing.overshoot: 0.7 }
        }
        Behavior on height {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        HoverHandler {
            id: submenuHover
            onHoveredChanged: {
                if (hovered) {
                    submenuCloseTimer.stop();
                } else {
                    submenuCloseTimer.restart();
                }
            }
        }

        Rectangle {
            id: submenuBg
            anchors.fill: parent
            color: root.colors.transparentBg
            radius: root.colors.radiusMedium
            border.color: root.colors.muted
            border.width: 2
            clip: true

            QsMenuOpener {
                id: submenuOpener
                menu: root.activeSubmenuItem
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 8
                contentWidth: width
                contentHeight: submenuColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                Column {
                    id: submenuColumn
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: submenuOpener.children

                        delegate: Item {
                            id: subMenuItem
                            required property var modelData

                            readonly property bool isSeparator: modelData.isSeparator
                            readonly property bool hasChildren: modelData.hasChildren
                            readonly property bool isEnabled: modelData.enabled !== false
                            readonly property int buttonType: modelData.buttonType !== undefined ? modelData.buttonType : 0
                            readonly property int checkState: modelData.checkState !== undefined ? modelData.checkState : 0
                            readonly property bool isHovered: subItemMouse.containsMouse
                            readonly property bool isDestructive: {
                                const txt = (modelData.text || "").toLowerCase();
                                return txt.includes("quit") || txt.includes("exit") || txt.includes("close") || txt.includes("remove") || txt.includes("disconnect");
                            }

                            width: submenuColumn.width
                            height: isSeparator ? 9 : 32
                            visible: modelData.text !== "" || isSeparator

                            Rectangle {
                                visible: subMenuItem.isSeparator
                                anchors.centerIn: parent
                                width: parent.width - 8
                                height: 1
                                color: root.colors.muted
                                opacity: 0.4
                            }

                            Rectangle {
                                visible: !subMenuItem.isSeparator
                                anchors.fill: parent
                                radius: root.colors.radiusSmall
                                color: subMenuItem.isHovered && subMenuItem.isEnabled
                                    ? (subMenuItem.isDestructive
                                        ? Qt.rgba(root.colors.red.r, root.colors.red.g, root.colors.red.b, 0.16)
                                        : Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.16))
                                    : "transparent"

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }

                            Rectangle {
                                visible: !subMenuItem.isSeparator && subMenuItem.isHovered && subMenuItem.isEnabled
                                width: 3
                                height: 16
                                radius: root.colors.radiusExtraSmall
                                color: subMenuItem.isDestructive ? root.colors.red : root.colors.accent
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            RowLayout {
                                visible: !subMenuItem.isSeparator
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8
                                opacity: subMenuItem.isEnabled ? 1.0 : 0.4

                                // Fixed 18px Gutter
                                Item {
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                    Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        anchors.centerIn: parent
                                        visible: subMenuItem.buttonType === 1
                                        width: 14
                                        height: 14
                                        radius: root.colors.radiusExtraSmall
                                        border.color: subMenuItem.checkState === Qt.Checked ? (subMenuItem.isDestructive ? root.colors.red : root.colors.accent) : root.colors.muted
                                        border.width: 1.5
                                        color: subMenuItem.checkState === Qt.Checked ? (subMenuItem.isDestructive ? root.colors.red : root.colors.accent) : "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            visible: subMenuItem.checkState === Qt.Checked
                                            text: "✓"
                                            color: root.colors.contrast
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }

                                    Rectangle {
                                        anchors.centerIn: parent
                                        visible: subMenuItem.buttonType === 2
                                        width: 14
                                        height: 14
                                        radius: 7
                                        border.color: subMenuItem.checkState === Qt.Checked ? (subMenuItem.isDestructive ? root.colors.red : root.colors.accent) : root.colors.muted
                                        border.width: 1.5
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            visible: subMenuItem.checkState === Qt.Checked
                                            width: 6
                                            height: 6
                                            radius: 3
                                            color: subMenuItem.isDestructive ? root.colors.red : root.colors.accent
                                        }
                                    }

                                    Image {
                                        id: subItemIcon
                                        anchors.centerIn: parent
                                        visible: subMenuItem.buttonType === 0 && modelData.icon !== undefined && modelData.icon !== "" && status !== Image.Error
                                        width: 16
                                        height: 16
                                        source: modelData.icon || ""
                                        fillMode: Image.PreserveAspectFit
                                        sourceSize.width: 16
                                        sourceSize.height: 16

                                        readonly property bool isSymbolic: {
                                            const src = (modelData.icon || "").toLowerCase();
                                            return src.includes("symbolic") || !src.endsWith(".png");
                                        }

                                        layer.enabled: isSymbolic
                                        layer.effect: ColorOverlay {
                                            color: subMenuItem.isHovered ? (subMenuItem.isDestructive ? root.colors.red : root.colors.accent) : root.colors.fg
                                        }
                                    }
                                }

                                Text {
                                    text: (modelData.text || "").replace(/_([a-zA-Z0-9])/g, "$1")
                                    color: subMenuItem.isHovered && subMenuItem.isEnabled
                                        ? (subMenuItem.isDestructive ? root.colors.red : root.colors.fg)
                                        : Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.9)
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                    font.family: root.colors.fontFamily
                                    font.weight: Font.Medium
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            MouseArea {
                                id: subItemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: subMenuItem.isEnabled && !subMenuItem.isSeparator
                                cursorShape: subMenuItem.isEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                                onClicked: {
                                    if (!subMenuItem.isEnabled || subMenuItem.isSeparator) return;
                                    modelData.triggered();
                                    root.close();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
