import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    width: 24
    height: 24

    required property string iconSource
    property color coloring: colors.fg

    Image {
        id: iconSource
        anchors.fill: parent
        source: root.iconSource
        sourceSize: Qt.size(parent.width, parent.height)
        visible: false
        smooth: true
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        anchors.fill: iconSource
        source: iconSource
        color: root.coloring
    }
}
