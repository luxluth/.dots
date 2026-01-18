//@ pragma UseQApplication
//@ pragma IconTheme WhiteSur

import Quickshell
import Quickshell.Wayland
import QtQuick
import "Core"
import "Modules"

ShellRoot {
    Context {
        id: ctx
        window: bar
    }
    Colors {
        id: colors
        context: ctx
    }

    PanelWindow {
        id: dashboardWindow

        visible: false
        screen: bar.screen
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

    Connections {
        target: bar.ccBtn

        function onClicked() {
            if (dashboardWindow.visible) {
                dashboard.close();
            } else {
                const pos = bar.ccBtn.mapToGlobal(0, 0);

                dashboardWindow.popupX = pos.x - dashboard.width + bar.ccBtn.width - 2;
                dashboardWindow.popupY = pos.y + bar.ccBtn.height + 10;

                dashboardWindow.visible = true;
                dashboard.open();
            }
        }
    }

    Bar {
        id: bar
        context: ctx
        colors: colors
        cc: dashboardWindow
    }

    PanelWindow {
        id: popupWindow
        screen: bar.screen
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
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "qs-pop"

        MouseArea {
            anchors.fill: parent
            onClicked: popupWindow.visible = false
        }

        Popup {
            id: popupContent
            anchors.centerIn: parent
            colors: colors
            onClosed: popupWindow.visible = false
        }
    }

    Osd {
        id: globalOsd
        colors: colors
    }

    NotificationOsd {
        colors: colors
        context: ctx
    }

    // Re-doing PanelWindow to be full screen overlay for click dismissal
    PanelWindow {
        id: notifHistoryOverlay
        visible: ctx.notificationPopupVisible || notifPopup.opacity > 0
        screen: bar.screen
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
        WlrLayershell.namespace: "qs-notif-history"

        MouseArea {
            anchors.fill: parent
            onClicked: ctx.notificationPopupVisible = false
        }

        NotificationPopup {
            id: notifPopup
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: bar.height + 5

            context: ctx
            colors: colors
            onClosed: ctx.notificationPopupVisible = false
        }
    }

    Connections {
        target: ctx
        function onToggleNotifications() {
            ctx.notificationPopupVisible = !ctx.notificationPopupVisible;
        }
        function onOsd(icon, title, subtitle) {
            globalOsd.show(icon, title, subtitle);
        }
        function onPopup(message, actions, defaultAction) {
            dashboard.close();
            popupContent.text = message;
            popupContent.actions = actions || [];
            popupContent.defaultAction = defaultAction || "";
            popupWindow.visible = true;
            popupContent.open();
        }
    }
}
