pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../Core"

Rectangle {
    id: root

    required property Colors colors
    property string text: ""
    property var actions: []
    property string defaultAction: ""
    signal closed

    width: 400
    height: Math.max(100, content.implicitHeight + 40)
    color: colors.bg
    border.color: colors.border
    border.width: 2
    radius: 8

    MouseArea {
        anchors.fill: parent
    }

    ColumnLayout {
        id: content
        anchors.centerIn: parent
        width: parent.width - 40
        spacing: 40

        Text {
            Layout.fillWidth: true
            text: root.text
            color: root.colors.fg
            font.family: root.colors.fontFamily
            font.bold: true
            font.pixelSize: 16
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            visible: root.actions && root.actions.length > 0
            spacing: 10

            Repeater {
                model: root.actions
                Rectangle {
                    id: btn
                    required property var modelData
                    property var actionData: modelData

                    implicitWidth: Math.max(300, btnText.contentWidth + 30)
                    implicitHeight: 36
                    radius: 5

                    property color baseColor: {
                        if (actionData.type === "D")
                            return root.colors.red;
                        if (actionData.id === root.defaultAction)
                            return root.colors.pearleBlue;
                        return root.colors.contrast;
                    }

                    color: {
                        if (mouseArea.pressed)
                            return Qt.darker(baseColor, 1.2);
                        if (mouseArea.containsMouse)
                            return Qt.lighter(baseColor, 1.1);
                        return baseColor;
                    }

                    border.color: root.colors.border
                    border.width: 2

                    Text {
                        id: btnText
                        anchors.centerIn: parent
                        text: btn.actionData.text
                        color: root.colors.fg
                        font.family: root.colors.fontFamily
                        font.pixelSize: 14
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            try {
                                btn.actionData._signal();
                            } catch (e) {}
                            root.closed();
                        }
                    }
                }
            }
        }
    }
}
