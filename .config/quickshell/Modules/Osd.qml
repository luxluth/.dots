pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../Components"
import "../Core"

Item {
    id: root

    required property Colors colors

    property string icon: ""
    property string title: ""
    property string subtitle: ""

    property bool shouldShowOsd: false
    property bool closing: false

    function show(icon, title, subtitle) {
        root.icon = icon;
        root.title = title;
        root.subtitle = subtitle;
        root.shouldShowOsd = true;
        root.closing = false;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.closing = true
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            anchors.bottom: true
            anchors.left: true
            margins.bottom: 20
            margins.left: 20
            exclusiveZone: 0

            WlrLayershell.namespace: "qs-osd"

            implicitWidth: 236
            implicitHeight: 70
            color: "transparent"

            mask: Region {}

            Item {
                id: container
                anchors.centerIn: parent
                width: 216
                height: 50

                opacity: 0
                scale: 0.9
                transformOrigin: Item.Center

                ParallelAnimation {
                    id: enterAnim
                    running: true
                    NumberAnimation {
                        target: container
                        property: "scale"
                        from: 0.9
                        to: 1.0
                        duration: 200
                        easing.type: Easing.OutBack
                    }
                    NumberAnimation {
                        target: container
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 150
                    }
                }

                ParallelAnimation {
                    id: exitAnim
                    onFinished: root.shouldShowOsd = false
                    NumberAnimation {
                        target: container
                        property: "scale"
                        from: 1.0
                        to: 0.9
                        duration: 150
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: container
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 100
                    }
                }

                Connections {
                    target: root
                    function onClosingChanged() {
                        if (root.closing) {
                            exitAnim.start();
                        } else {
                            exitAnim.stop();
                            enterAnim.start();
                        }
                    }
                }

                Rectangle {
                    id: outer
                    anchors.fill: parent
                    radius: 20
                    color: Qt.rgba(colors.bg.r, colors.bg.g, colors.bg.b, 0.9)
                    border.width: 1
                    border.color: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.1)

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 20
                            rightMargin: 20
                        }
                        spacing: 15

                        CImage {
                            iconSource: root.icon
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: root.title
                                color: colors.fg
                                font.bold: true
                                font.pixelSize: 14
                                font.family: colors.fontFamily
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.subtitle
                                color: Qt.lighter(colors.fg, 1.5)
                                font.pixelSize: 12
                                font.family: colors.fontFamily
                                elide: Text.ElideRight
                                visible: root.subtitle.length > 0
                            }
                        }
                    }
                }
            }
        }
    }
}
