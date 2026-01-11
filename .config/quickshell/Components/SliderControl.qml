import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Item {
    id: root

    property real value: .0

    signal changeRequested(real newValue)

    Layout.fillWidth: true
    implicitHeight: 34

    ClippingRectangle {
        id: track
        anchors.fill: parent
        radius: 6
        color: colors.contrast
        border.width: 2
        border.color: colors.border

        Rectangle {
            id: ranged
            anchors.left: parent.left
            anchors.top: parent.top
            height: parent.height
            width: parent.width * root.value
            color: colors.fg
        }
    }

    Rectangle {
        id: rangeAnchor
        x: (track.width * root.value) - (width / 2)
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height + 8
        width: 8
        radius: 4
        color: colors.fg
        scale: sliderEvent.containsPress ? 0.95 : 1.0
        border.color: colors.border

        Behavior on scale {
            NumberAnimation {
                duration: 100
            }
        }
    }

    MouseArea {
        id: sliderEvent
        anchors.fill: parent
        hoverEnabled: true
        onPressed: mouse => updateValue(mouse.x)
        onPositionChanged: mouse => updateValue(mouse.x)

        function updateValue(mouseX) {
            if (sliderEvent.pressed) {
                const newValue = Math.max(0, Math.min(1, mouseX / width));
                root.value = newValue;
                root.changeRequested(newValue);
            }
        }
    }
}
