pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Core"

Item {
    id: root

    required property Colors colors
    required property Context context

    property bool isHyprland: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").toLowerCase() === "hyprland"
    property bool shouldShow: false
    property bool closing: false
    property int lastWorkspaceId: -1

    readonly property var currentWorkspace: root.context.compositor.focusedWorkspace
    readonly property int currentWorkspaceId: currentWorkspace?.id ?? -1

    readonly property var displayWorkspaces: {
        let raw = root.context.compositor.workspaces || [];
        let list = raw.filter(w => w.id > 0);
        let cur = root.currentWorkspace;
        if (cur && cur.id > 0 && !list.some(w => w.id === cur.id)) {
            list.push(cur);
        }
        list.sort((a, b) => a.id - b.id);
        return list;
    }

    function trigger() {
        root.shouldShow = true;
        root.closing = false;
        cooldownTimer.restart();
    }

    function close() {
        root.closing = true;
    }

    Timer {
        id: cooldownTimer
        interval: 1800
        repeat: false
        onTriggered: root.closing = true
    }

    Connections {
        target: root.context.compositor
        function onFocusedWorkspaceChanged() {
            const newId = root.currentWorkspaceId;
            if (newId === -1)
                return;

            if (root.lastWorkspaceId === -1) {
                root.lastWorkspaceId = newId;
                return;
            }

            if (newId !== root.lastWorkspaceId) {
                root.lastWorkspaceId = newId;
                root.trigger();
            }
        }
    }

    IpcHandler {
        target: "workspace"

        function trigger(): void {
            root.trigger();
        }
        function toggle(): void {
            if (root.shouldShow && !root.closing) {
                root.close();
            } else {
                root.trigger();
            }
        }
        function open(): void {
            root.trigger();
        }
        function show(): void {
            root.trigger();
        }
        function hide(): void {
            root.close();
        }
        function close(): void {
            root.close();
        }
    }

    IpcHandler {
        target: "workspaces"

        function trigger(): void {
            root.trigger();
        }
        function toggle(): void {
            if (root.shouldShow && !root.closing) {
                root.close();
            } else {
                root.trigger();
            }
        }
        function open(): void {
            root.trigger();
        }
        function show(): void {
            root.trigger();
        }
        function hide(): void {
            root.close();
        }
        function close(): void {
            root.close();
        }
    }

    LazyLoader {
        active: root.shouldShow

        PanelWindow {
            id: window

            screen: {
                const mon = root.currentWorkspace?.monitor;
                if (mon) {
                    const found = Quickshell.screens.find(s => s.name === mon);
                    if (found)
                        return found;
                }
                return root.context.window ? root.context.window.screen : Quickshell.screens[0];
            }

            anchors {
                top: true
            }
            margins.top: (root.isHyprland ? 40 : 30) + 20

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs-workspace-indicator"
            WlrLayershell.exclusiveZone: -1
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            implicitWidth: container.implicitWidth
            implicitHeight: container.implicitHeight
            color: "transparent"

            Item {
                id: container

                implicitWidth: outerRect.implicitWidth
                implicitHeight: outerRect.implicitHeight
                width: implicitWidth
                height: implicitHeight

                opacity: 0
                y: -10

                ParallelAnimation {
                    id: enterAnim
                    running: true
                    NumberAnimation {
                        target: container
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: container
                        property: "y"
                        from: -10
                        to: 0
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                ParallelAnimation {
                    id: exitAnim
                    onFinished: root.shouldShow = false
                    NumberAnimation {
                        target: container
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 150
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: container
                        property: "y"
                        from: 0
                        to: -8
                        duration: 150
                        easing.type: Easing.InCubic
                    }
                }

                Connections {
                    target: root
                    function onClosingChanged() {
                        if (root.closing) {
                            exitAnim.start();
                        } else {
                            exitAnim.stop();
                            enterAnim.start();
                        }
                    }
                }

                Rectangle {
                    id: outerRect
                    anchors.centerIn: parent
                    implicitHeight: 48
                    implicitWidth: Math.max(60, row.width + 12)
                    width: implicitWidth
                    height: implicitHeight
                    radius: root.colors.radiusBase
                    color: root.colors.transparentBg
                    border.width: 2
                    border.color: root.colors.muted

                    HoverHandler {
                        onHoveredChanged: {
                            if (hovered) {
                                cooldownTimer.stop();
                            } else {
                                cooldownTimer.restart();
                            }
                        }
                    }

                    Row {
                        id: row
                        anchors.centerIn: parent
                        spacing: 6

                        Repeater {
                            model: root.displayWorkspaces

                            delegate: Rectangle {
                                id: wsPill

                                required property var modelData
                                property var ws: modelData
                                property bool isActive: ws.id === root.currentWorkspaceId
                                property bool hasWindows: (ws.windows ?? 0) > 0

                                implicitHeight: 36
                                implicitWidth: Math.max(36, idText.contentWidth + 12)
                                width: implicitWidth
                                height: implicitHeight
                                radius: root.colors.radiusSmall

                                color: {
                                    if (isActive)
                                        return root.colors.accent;
                                    if (pillMouse.containsMouse)
                                        return Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.25);
                                    return Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.08);
                                }

                                border.width: 1
                                border.color: isActive ? root.colors.accentOutline : root.colors.muted

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }

                                Text {
                                    id: idText
                                    anchors.centerIn: parent
                                    text: wsPill.ws.name || wsPill.ws.id
                                    font.family: root.colors.fontFamily
                                    font.pixelSize: 15
                                    font.bold: true

                                    color: {
                                        if (wsPill.isActive)
                                            return root.colors.bg;
                                        if (wsPill.hasWindows)
                                            return root.colors.fg;
                                        return root.colors.transparentFg;
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }
                                }

                                MouseArea {
                                    id: pillMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.RightButton) {
                                            root.close();
                                        } else {
                                            root.context.compositor.gotoWorkspace(wsPill.ws.id);
                                            cooldownTimer.restart();
                                        }
                                    }
                                    onWheel: wheel => {
                                        const step = wheel.angleDelta.y / 120;
                                        if (step !== 0) {
                                            root.context.compositor.gotoWorkspaceStep(-step);
                                            cooldownTimer.restart();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
