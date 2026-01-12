//@ pragma UseQApplication

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
}
