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
    radius: colors.radiusMedium

    scale: 0.9
    opacity: 0
    transform: Translate {
        id: trans
        y: 20
    }

    function open() {
        enterAnim.start();
    }

    function close() {
        exitAnim.start();
    }

    ParallelAnimation {
        id: enterAnim
        NumberAnimation {
            target: root
            property: "scale"
            from: 0.9
            to: 1.0
            duration: 200
            easing.type: Easing.OutBack
        }
        NumberAnimation {
            target: root
            property: "opacity"
            from: 0
            to: 1
            duration: 150
        }
        NumberAnimation {
            target: trans
            property: "y"
            from: 20
            to: 0
            duration: 250
            easing.type: Easing.OutQuart
        }
    }

    ParallelAnimation {
        id: exitAnim
        onFinished: root.closed()
        NumberAnimation {
            target: root
            property: "scale"
            from: 1.0
            to: 0.9
            duration: 150
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: root
            property: "opacity"
            from: 1
            to: 0
            duration: 100
        }
        NumberAnimation {
            target: trans
            property: "y"
            from: 0
            to: 20
            duration: 150
            easing.type: Easing.InQuad
        }
    }

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
                    radius: root.colors.radius5

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
                            root.close();
                        }
                    }
                }
            }
        }
    }
}
