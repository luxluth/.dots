import Quickshell
import QtQuick
import QtQuick.Layouts

import "../Assets/"

import "."

Rectangle {
    id: root

    required property string title
    required property string icon
    property bool isActive: false
    property bool expansion: true
    property string details: ""

    signal clicked
    signal arrowClicked

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 4
    height: 60

    border.color: isActive ? colors.pearleBlueStroke : colors.border
    color: isActive ? colors.pearleBlue : colors.contrast
    border.width: isActive ? 2 : 1

    // Hover and Click animations
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

    SequentialAnimation {
        id: clickAnim
        NumberAnimation {
            target: root
            property: "scale"
            to: 0.97
            duration: 50
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1.0
            duration: 150
            easing.type: Easing.OutBack
        }
    }

    Rectangle {
        id: hoverOverlay
        anchors.fill: parent
        color: "white"
        opacity: (mainMouse.containsMouse || arrowMouse.containsMouse) ? 0.05 : 0
        radius: root.radius
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 8
                spacing: 12

                CImage {
                    iconSource: root.icon
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        text: root.title
                        color: colors.fg
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font {
                            family: "Inter"
                            pixelSize: 18
                            bold: true
                        }
                    }

                    Text {
                        text: root.details
                        color: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.6)
                        visible: root.details !== ""
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font {
                            family: "Inter"
                            pixelSize: 13
                        }
                    }
                }
            }

            MouseArea {
                id: mainMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    clickAnim.start();
                    root.clicked();
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 2
            Layout.fillHeight: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            visible: root.expansion
            color: root.isActive ? colors.pearleBlueStroke : colors.border
        }

        Item {
            id: arrowItem
            Layout.preferredWidth: 50
            Layout.fillHeight: true
            visible: root.expansion

            CImage {
                anchors.centerIn: parent
                width: 32
                height: 32
                iconSource: Icons.chevronRight
            }

            MouseArea {
                id: arrowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    clickAnim.start();
                    root.arrowClicked();
                }
            }
        }
    }
}
