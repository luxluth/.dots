import Quickshell
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
    }

    PopupWindow {
        id: dashboardWindow

        anchor.window: bar // Anchor to your bar?
        anchor.edges: Edges.Top | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left

        implicitWidth: 600
        implicitHeight: 500

        property rect clickedRect: Qt.rect(0, 0, 0, 0)
        anchor.rect: clickedRect

        color: "transparent" // The ControlCenter has its own background

        // Load the module
        ControlCenter {
            anchors.fill: parent
        }
    }

    Connections {
        target: bar.ccBtn

        function onClicked() {
            const pos = bar.ccBtn.mapToItem(bar.contentItem, 0, 0);
            dashboardWindow.clickedRect = Qt.rect(pos.x, pos.y + 35, bar.ccBtn.width, bar.ccBtn.height);

            dashboardWindow.visible = !dashboardWindow.visible;
        }
    }

    Bar {
        id: bar
    }
}
