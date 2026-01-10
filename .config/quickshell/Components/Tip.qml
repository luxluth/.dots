import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property PanelWindow rootWindow
    required property Item targetItem
    required property MouseArea watcher

    property string text: ""
    property int delay: 500
    property int padding: 8

    property bool _timerFinished: false
    visible: watcher.containsMouse && _timerFinished

    Timer {
        running: root.watcher.containsMouse && !root._timerFinished
        interval: root.delay

        onTriggered: {
            const pos = root.targetItem.mapToItem(root.rootWindow.contentItem, 0, 0);
            root.calculatedRect = Qt.rect(pos.x, pos.y, root.targetItem.width, root.targetItem.height);
            root._timerFinished = true;
        }
    }

    Connections {
        target: root.watcher
        function onContainsMouseChanged() {
            if (!root.watcher.containsMouse) {
                root._timerFinished = false;
            }
        }
    }

    property rect calculatedRect: Qt.rect(0, 0, 0, 0)

    anchor.window: rootWindow
    anchor.rect: calculatedRect

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom // Ensures it snaps to the bottom edge

    implicitWidth: content.width
    implicitHeight: content.height
    color: "transparent"

    Rectangle {
        id: content

        implicitWidth: label.implicitWidth + (root.padding * 2)
        implicitHeight: label.implicitHeight + (root.padding * 2)

        color: colors.bg
        border.color: colors.muted
        border.width: 1
        radius: 4

        states: State {
            name: "visible"
            when: root.visible
            PropertyChanges {
                target: content
                opacity: 1.0
            }
        }

        transitions: Transition {
            NumberAnimation {
                property: "opacity"
                duration: 200
            }
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            color: colors.fg
            font {
                family: colors.fontFamily
                pixelSize: 12
                bold: true
            }
        }
    }
}
