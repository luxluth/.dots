import QtQuick
import QtQuick.Layouts
import "../Assets/"
import "../Core"

Rectangle {
    id: root

    required property Colors colors
    property string placeholderText: ""
    property string text: ""
    property bool isPassword: false
    property bool revealPassword: false

    signal accepted

    implicitWidth: 320
    implicitHeight: 38
    color: colors.contrast
    border.color: textInput.activeFocus ? colors.accent : colors.border
    border.width: textInput.activeFocus ? 2 : 1
    radius: colors.radiusSmall

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 6
        spacing: 8

        TextInput {
            id: textInput
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            color: root.colors.fg
            text: root.text
            echoMode: root.isPassword && !root.revealPassword ? TextInput.Password : TextInput.Normal
            font.family: root.colors.fontFamily
            font.pixelSize: 16
            clip: true
            selectByMouse: true

            onTextChanged: {
                if (root.text !== text) {
                    root.text = text;
                }
            }

            Text {
                text: root.placeholderText
                color: root.colors.transparentFg
                visible: !textInput.text && !textInput.activeFocus
                font.family: root.colors.fontFamily
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            onAccepted: root.accepted()
        }

        // Toggle visibility button for password fields
        Item {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            visible: root.isPassword

            Rectangle {
                id: toggleBg
                anchors.fill: parent
                color: "white"
                opacity: toggleMouse.containsMouse ? 0.08 : 0
                radius: root.colors.radiusSmall
                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
            }

            CImage {
                anchors.centerIn: parent
                width: 18
                height: 18
                iconSource: root.revealPassword ? Icons.eye : Icons.eyeOff
                coloring: root.colors.transparentFg
            }

            MouseArea {
                id: toggleMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.revealPassword = !root.revealPassword
            }
        }
    }

    function forceActiveFocus() {
        textInput.forceActiveFocus();
    }

    function clear() {
        textInput.text = "";
        root.revealPassword = false;
    }
}
