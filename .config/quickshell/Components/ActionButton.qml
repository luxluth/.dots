pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "."
import "../Core"

Rectangle {
    id: root
    required property var model
    required property Context context
    required property Colors colors

    property bool active: model.active
    property string icon: model.icon
    /**
    * @param {Item} item - The button instance
    * @param {Process} process - The process helper
    **/
    property var action: model.action
    property color coloring: model.color ?? root.colors.fg

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: colors.radiusCompact
    color: model.active ? colors.fg : colors.contrast
    border.color: colors.border
    border.width: 2

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }
    }

    scale: mouseArea.pressed ? 0.97 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 100
        }
    }

    Rectangle {
        id: hoverOverlay
        anchors.fill: parent
        color: "white"
        opacity: mouseArea.containsMouse ? 0.05 : 0
        radius: root.radius
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    CImage {
        anchors.centerIn: parent
        coloring: root.active ? root.colors.contrast : root.coloring
        iconSource: root.icon
        width: 24
        height: 24
    }

    Process {
        id: actionProcessHelper
        running: false
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.action(root, actionProcessHelper, root.active)
    }
}
