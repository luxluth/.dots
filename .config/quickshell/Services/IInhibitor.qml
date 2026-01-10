import QtQuick
import Quickshell.Wayland

Item {
    id: root

    required property QtObject binding

    property IdleInhibitor state: IdleInhibitor {
        window: root.binding
        enabled: false
    }
}
