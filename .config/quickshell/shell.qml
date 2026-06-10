//@ pragma UseQApplication
//@ pragma IconTheme WhiteSur

import Quickshell
import Quickshell.Wayland
import QtQuick
import "Core"
import "Modules"

ShellRoot {
    id: root

    property alias rootColors: colors

    Context {
        id: ctx
        window: bars.instances.length > 0 ? bars.instances[0] : null
    }
    Colors {
        id: colors
        context: ctx
    }

    PanelWindow {
        id: dashboardWindow

        visible: false
        screen: bars.instances.length > 0 ? bars.instances[0].screen : null
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "qs-cc"

        property real popupX: 0
        property real popupY: 0

        MouseArea {
            anchors.fill: parent
            onClicked: dashboard.close()
        }

        // Load the module
        ControlCenter {
            id: dashboard
            x: dashboardWindow.popupX
            y: dashboardWindow.popupY
            context: ctx
            colors: colors
            statusVisible: dashboardWindow.visible
            onClosed: dashboardWindow.visible = false
        }
    }

    Variants {
        id: bars
        model: Quickshell.screens
        delegate: Bar {
            id: barInstance
            required property var modelData
            screen: modelData
            context: ctx
            colors: root.rootColors
            cc: dashboardWindow
            WlrLayershell.namespace: "qs-bar"

            Connections {
                target: barInstance.ccBtn
                function onClicked() {
                    if (dashboardWindow.visible && dashboardWindow.screen === barInstance.screen) {
                        dashboard.close();
                    } else {
                        dashboardWindow.screen = barInstance.screen;
                        const pos = barInstance.ccBtn.mapToGlobal(0, 0);

                        dashboardWindow.popupX = pos.x - dashboard.width + barInstance.ccBtn.width - 2;
                        dashboardWindow.popupY = pos.y + barInstance.ccBtn.height + 10;

                        dashboardWindow.visible = true;
                        dashboard.open();
                    }
                }
            }
        }
    }

    PanelWindow {
        id: popupWindow
        screen: bars.instances.length > 0 ? bars.instances[0].screen : null
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        visible: false

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: popupWindow.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        WlrLayershell.namespace: "qs-pop"

        MouseArea {
            anchors.fill: parent
            onClicked: popupContent.close()
        }

        Popup {
            id: popupContent
            anchors.centerIn: parent
            colors: colors
            onClosed: {
                popupWindow.visible = false;
                if (popupContent.shouldRestoreDashboard) {
                    restoreTimer.start();
                }
                popupContent.isPasswordPrompt = false;
                popupContent.shouldRestoreDashboard = false;
            }
        }
    }

    Osd {
        id: globalOsd
        colors: colors
        context: ctx
    }

    NotificationOsd {
        colors: colors
        context: ctx
    }

    Connections {
        target: ctx
        function onOsd(icon, title, subtitle) {
            globalOsd.show(icon, title, subtitle);
        }
        function onPopup(message, actions, defaultAction) {
            dashboard.close();
            popupContent.text = message;
            popupContent.actions = actions || [];
            popupContent.defaultAction = defaultAction || "";
            popupContent.shouldRestoreDashboard = message.indexOf("Failed to connect") !== -1;
            popupWindow.visible = true;
            popupContent.open();
        }
        function onPasswordPrompt(title, callback) {
            dashboard.close();
            popupContent.text = title;
            popupContent.isPasswordPrompt = true;
            popupContent.shouldRestoreDashboard = true;
            popupContent.actions = [
                {
                    id: "cancel",
                    text: "Cancel",
                    _signal: () => { }
                },
                {
                    id: "connect",
                    text: "Connect",
                    _signal: () => {
                        callback(popupContent.enteredPassword);
                    }
                }
            ];
            popupContent.defaultAction = "connect";
            popupWindow.visible = true;
            popupContent.open();
        }
    }

    Timer {
        id: restoreTimer
        interval: 50
        repeat: false
        onTriggered: {
            dashboardWindow.visible = true;
            dashboard.open();
        }
    }
}
