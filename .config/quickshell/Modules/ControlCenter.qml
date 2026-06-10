import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell

import "../Assets/"
import "../Components/"
import "../Core"
import "." as Mod

Rectangle {
    id: root

    required property Context context
    required property Colors colors
    required property bool statusVisible

    width: 600
    height: 900
    color: colors.transparentBg
    radius: colors.radiusExtraLarge
    border.color: colors.border
    border.width: 2

    property ControlCenterActions actions: controlActions

    ControlCenterActions {
        id: controlActions
        context: root.context
        colors: root.colors
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: mouse => mouse.accepted = true
    }

    // Animation properties
    transformOrigin: Item.TopRight
    scale: 0.9
    opacity: 0

    transform: Translate {
        id: trans
        y: -20
    }

    // Signal to notify parent when closing animation is done
    signal closed

    function close() {
        exitAnim.start();
    }

    function open() {
        enterAnim.start();
    }

    // Enter Animation
    ParallelAnimation {
        id: enterAnim
        running: true
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
            from: -20
            to: 0
            duration: 250
            easing.type: Easing.OutQuart
        }
    }

    // Exit Animation
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
            to: -20
            duration: 150
            easing.type: Easing.InQuad
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: 2
            columnSpacing: 8
            rowSpacing: 8

            // TOP LEFT: Connectivity
            Rectangle {
                Layout.column: 0
                Layout.row: 0

                // Sizing
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: root.width * 0.45
                Layout.preferredHeight: root.height * 0.6

                radius: root.colors.radiusMedium
                border.color: root.colors.border
                border.width: 2
                color: root.colors.contrast

                QuickSettings {
                    anchors.fill: parent
                    context: root.context
                    colors: root.colors
                    active: root.statusVisible
                }
            }

            // Placeholders for other sections
            // LEFT BOTTOM
            Rectangle {
                Layout.column: 0
                Layout.row: 1
                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.preferredWidth: root.width * 0.45
                Layout.preferredHeight: root.height * 0.6
                color: "transparent"

                FlexboxLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    direction: FlexboxLayout.Column
                    gap: 10
                    justifyContent: FlexboxLayout.JustifySpaceBetween

                    // VOLUME
                    Rectangle {
                        radius: root.colors.radiusMedium
                        border.color: root.colors.border
                        border.width: 2
                        color: root.colors.contrast

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        height: 190

                        opacity: (root.context.pw.sink?.audio.muted ?? false) ? 0.4 : 1

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 100
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Text {
                                text: "Volume"
                                color: root.colors.fg
                                font {
                                    family: root.colors.fontFamily
                                    pixelSize: 18
                                    bold: true
                                }
                                Layout.fillWidth: true
                            }

                            Text {
                                text: `Fixed at ${Math.round(volSlider.value * 100)}%`
                                color: Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.6)
                                font {
                                    family: root.colors.fontFamily
                                    pixelSize: 13
                                }
                                Layout.fillWidth: true
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                SliderControl {
                                    id: volSlider
                                    Layout.fillWidth: true
                                    value: (root.context.pw.sink?.audio.volume ?? 0)
                                    onChangeRequested: v => root.context.pw.sink.audio.volume = v
                                }

                                Rectangle {
                                    implicitWidth: 40
                                    implicitHeight: 40
                                    radius: root.colors.radiusBase
                                    border.color: root.colors.border
                                    border.width: 2
                                    color: root.context.pw.sink.audio.muted ? root.colors.fg : root.colors.contrast

                                    scale: muteButtonMouse.containsPress ? 0.95 : 1

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 90
                                        }
                                    }
                                    CImage {
                                        coloring: root.context.pw.sink.audio.muted ? root.colors.bg : root.colors.fg
                                        anchors.centerIn: parent
                                        iconSource: Icons.volumeMute
                                    }

                                    MouseArea {
                                        id: muteButtonMouse
                                        anchors.fill: parent

                                        onClicked: root.context.pw.sink.audio.muted = !root.context.pw.sink.audio.muted
                                    }
                                }
                            }

                            Connections {
                                target: root.context.pw.sink.audio

                                function onVolumeChanged() {
                                    volSlider.value = root.context.pw.sink.audio.volume;
                                }
                            }
                        }
                    }

                    // BRIGHTNESS
                    Rectangle {
                        radius: root.colors.radiusMedium
                        border.color: root.colors.border
                        border.width: 2
                        color: root.colors.contrast

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        height: 190

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Text {
                                text: "Brightness"
                                color: root.colors.fg

                                font {
                                    family: root.colors.fontFamily
                                    pixelSize: 18
                                    bold: true
                                }
                                Layout.fillWidth: true
                            }

                            Text {
                                text: `Fixed at ${Math.round(brightnessSlider.value * 100)}%`
                                color: Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.6)
                                font {
                                    family: root.colors.fontFamily
                                    pixelSize: 13
                                }
                                Layout.fillWidth: true
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            SliderControl {
                                id: brightnessSlider
                                Layout.fillWidth: true
                                value: root.context.brightness.brightness
                                onChangeRequested: v => root.context.brightness.setBrightness(v)
                            }
                        }
                    }
                }
            }

            // RIGHT TOP - Info + Quick Actions
            Rectangle {
                Layout.column: 1
                Layout.row: 0
                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.preferredWidth: root.width * 0.45
                Layout.preferredHeight: root.height * 0.6

                radius: root.colors.radiusMedium
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    // Uptime + UserData
                    Rectangle {
                        radius: root.colors.radiusMedium
                        border.color: root.colors.border
                        border.width: 2
                        color: colorQuantizer.selection

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        height: 40

                        ColorQuantizer {
                            id: colorQuantizer
                            source: root.context.system.avatar
                            depth: 3
                            rescaleSize: 64

                            property color selection: {
                                if (colorQuantizer.colors.length <= 0) {
                                    return root.colors.bg;
                                }
                                var qcolors = [...colorQuantizer.colors];
                                qcolors.sort((a, b) => root.colors.isDarkThemed ? a.hslLightness - b.hslLightness : b.hslLightness - a.hslLightness);
                                return qcolors[0];
                            }
                        }

                        RowLayout {
                            anchors.margins: 10
                            anchors.fill: parent
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text {
                                    text: root.context.system.uptime
                                    color: root.colors.fg

                                    font {
                                        family: root.colors.fontFamily
                                        pixelSize: 18
                                        bold: true
                                    }
                                }

                                RowLayout {
                                    Text {
                                        color: root.colors.fg
                                        text: "connected as"
                                        font {
                                            family: root.colors.fontFamily
                                        }
                                        opacity: 0.7
                                    }

                                    Text {
                                        color: root.colors.fg
                                        text: root.context.system.username
                                        font {
                                            family: root.colors.fontFamily
                                            bold: true
                                        }
                                    }
                                }
                            }

                            // Avatar
                            Item {
                                width: 48
                                height: 48
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                                Image {
                                    id: avatarImage
                                    anchors.fill: parent
                                    source: root.context.system.avatar
                                    sourceSize: Qt.size(128, 128)
                                    fillMode: Image.PreserveAspectCrop
                                    visible: false
                                    smooth: true
                                    mipmap: true
                                }

                                OpacityMask {
                                    anchors.fill: avatarImage
                                    source: avatarImage
                                    smooth: true
                                    maskSource: Rectangle {
                                        width: avatarImage.width
                                        height: avatarImage.height
                                        radius: width / 2
                                        antialiasing: true
                                        visible: false
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: "transparent"
                                    border.color: root.colors.fg
                                    border.width: 2
                                    opacity: 0.5
                                    antialiasing: true
                                }
                            }
                        }
                    }

                    // Actions
                    Rectangle {
                        radius: root.colors.radiusMedium
                        border.color: root.colors.border
                        border.width: 2
                        color: root.colors.contrast

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        height: 100

                        GridLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            columns: 3
                            rowSpacing: 8
                            columnSpacing: 8

                            Repeater {
                                model: root.actions.actions
                                delegate: ActionButton {
                                    required property var modelData
                                    model: modelData
                                    context: root.context
                                    colors: root.colors
                                }
                            }
                        }
                    }
                }
            }

            // RIGHT BOTTOM - MPRIS
            MprisControl {
                Layout.column: 1
                Layout.row: 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                colors: root.colors
                context: root.context
            }
        }

        Mod.NotificationView {
            colors: root.colors
            context: root.context
            onClosed: root.close()
        }
    }
}
