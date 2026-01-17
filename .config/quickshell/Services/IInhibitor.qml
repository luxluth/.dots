import QtQuick
import Quickshell.Wayland
import "../Assets"

Item {
    id: root

    required property QtObject binding

    signal statusChanged(string icon, string title, string subtitle)

    property IdleInhibitor state: IdleInhibitor {
        window: root.binding
        enabled: false

        onEnabledChanged: {
            const title = enabled ? "Caffeine Activated" : "Caffeine Deactivated";
            const icon = Icons.coffee;
            root.statusChanged(icon, title, enabled ? "System will not sleep" : "System can sleep");
        }
    }
}
