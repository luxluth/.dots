import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io

import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray // For system actions if available, or just shell commands

import "../Assets/"
import "../Components/"

// We wrap the whole thing in a component we can use inside a PopupWindow
Rectangle {
    id: root
    width: 600
    height: 500
    color: colors.bg
    radius: 16
    border.color: colors.border
    border.width: 2

    GridLayout {
        anchors.fill: parent
        anchors.margins: 8

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
            Layout.preferredWidth: parent.width * 0.45
            Layout.preferredHeight: parent.height * 0.6

            radius: 8

            border.color: colors.border
            border.width: 2
            color: colors.contrast

            FlexboxLayout {

                anchors.fill: parent
                anchors.margins: 8

                direction: FlexboxLayout.Column

                gap: 10
                alignItems: FlexboxLayout.Stretch
                justifyContent: FlexboxLayout.JustifySpaceAround

                StateButton {
                    title: "Wi-Fi"
                    icon: Icons.wifiHigh
                    isActive: true
                    onClicked: {
                        // Logic to toggle Wifi
                        isActive = !isActive;
                    }
                    onArrowClicked: {
                        // Logic to open Wifi Menu
                        console.log("Open Wifi Settings");
                    }
                }
                StateButton {
                    title: "Bluetooth"
                    icon: !ctx.blt.adapter.enabled ? Icons.bluetoothOff : (ctx.blt.connected ? Icons.bluetoothConnected : Icons.bluetoothActive)
                    isActive: ctx.blt.adapter.enabled
                    details: ctx.blt.connected ? `${ctx.blt.connected.name} ${ctx.blt.connected.batteryAvailable ? (ctx.blt.connected.battery * 100).toString() + "%" : ""}` : "$ Not Paired"

                    onClicked: () => {
                        if (ctx.blt.adapter.enabled) {
                            for (const device of ctx.blt.devices) {
                                if (device.connected) {
                                    device.disconnect();
                                }
                            }
                        }
                        ctx.blt.adapter.enabled = !ctx.blt.adapter.enabled;
                    }
                }
                StateButton {
                    title: "Power Profile"
                    icon: {
                        if (ctx.power.profile == 0)
                            return Icons.scale;
                        if (ctx.power.profile == 1)
                            return Icons.zap;
                        if (ctx.power.profile == 2)
                            return Icons.sproot;
                    }
                    expansion: false
                    isActive: ctx.power.profile > 0
                    details: ctx.power.profileToText(ctx.power.profile).replace("-", " ").toUpperCase()

                    onClicked: () => {
                        ctx.power.cycle();
                    }
                }
            }
        }

        // LEFT BOTTOM
        Rectangle {
            Layout.column: 0
            Layout.row: 1

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth: parent.width * 0.45
            Layout.preferredHeight: parent.height * 0.6

            radius: 8
            border.color: "transparent" // colors.border
            border.width: 2

            color: "transparent"

            // ColumnLayout {
            //     Layout.fillWidth: true
            //     spacing: 10
            // }
        }

        // RIGHT TOP
        Rectangle {
            Layout.column: 1
            Layout.row: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth: parent.width * 0.45
            Layout.preferredHeight: parent.height * 0.6

            radius: 8
            border.color: "transparent" // colors.border
            border.width: 2

            color: "transparent"

            // ColumnLayout {
            //     Layout.fillWidth: true
            //     spacing: 10
            // }
        }

        // RIGHT BOTTOM
        Rectangle {
            Layout.column: 1
            Layout.row: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: 8
            border.color: "transparent" // colors.border
            border.width: 2

            color: "transparent"

            // ColumnLayout {
            //     Layout.fillWidth: true
            //     spacing: 10
            // }
        }
    }

    // We split the view into two main columns
    // RowLayout {
    //     anchors.fill: parent
    //     anchors.margins: 16
    //     spacing: 16
    //
    //     // ============================================================
    //     // LEFT COLUMN (Connectivity + Sliders)
    //     // ============================================================
    //     ColumnLayout {
    //         Layout.fillHeight: true
    //         Layout.preferredWidth: parent.width * 0.45
    //         spacing: 16
    //
    //         // --- 1. Connectivity Group ---
    //         ColumnLayout {
    //             Layout.fillWidth: true
    //             spacing: 10
    //
    //             ToggleBtn {
    //                 title: "Wi-Fi"
    //                 subtitle: "WiFi-5.0-C832"
    //                 icon: "network-wireless"
    //                 checked: true
    //                 onClicked: checked = !checked
    //             }
    //
    //             ToggleBtn {
    //                 title: "Bluetooth"
    //                 subtitle: "Galaxy Buds 90%"
    //                 icon: "bluetooth"
    //                 checked: true
    //                 onClicked: checked = !checked
    //             }
    //
    //             // Simple Button (Power Profile)
    //             Rectangle {
    //                 Layout.fillWidth: true
    //                 Layout.preferredHeight: 60
    //                 radius: 8
    //                 color: "#2a2a2a"
    //                 border.color: "#333333"
    //
    //                 RowLayout {
    //                     anchors.fill: parent
    //                     anchors.margins: 15
    //                     spacing: 12
    //
    //                     Image {
    //                         source: "image://icon/power-profile-balanced" // generic icon name
    //                         Layout.preferredWidth: 24
    //                         Layout.preferredHeight: 24
    //                     }
    //                     ColumnLayout {
    //                         Text {
    //                             text: "Power Profile"
    //                             color: "white"
    //                             font.bold: true
    //                             font.pixelSize: 14
    //                         }
    //                         Text {
    //                             text: "Balanced"
    //                             color: "#999999"
    //                             font.pixelSize: 11
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //
    //         // Spacer
    //         Item {
    //             Layout.fillHeight: true
    //         }
    //
    //         // --- 2. Sliders Group ---
    //         ColumnLayout {
    //             Layout.fillWidth: true
    //             spacing: 12
    //
    //             // Volume Slider (Hooked to Pipewire)
    //             CustomSlider {
    //                 label: "Volume"
    //                 // Access global 'ctx' if available, otherwise mock
    //                 // value: ctx.pw.sink.audio.volume * 100
    //                 statusText: "Fixed at " + Math.floor(value) + "%"
    //             }
    //
    //             CustomSlider {
    //                 label: "Brightness"
    //                 statusText: "Fixed at " + Math.floor(value) + "%"
    //                 value: 100
    //             }
    //         }
    //     }
    //
    //     // ============================================================
    //     // RIGHT COLUMN (Battery, System, Media)
    //     // ============================================================
    //     ColumnLayout {
    //         Layout.fillHeight: true
    //         Layout.fillWidth: true
    //         spacing: 16
    //
    //         // --- 3. Battery & System Row ---
    //         RowLayout {
    //             Layout.fillWidth: true
    //             Layout.preferredHeight: 100
    //             spacing: 16
    //
    //             // Battery Big Block
    //             Rectangle {
    //                 Layout.fillHeight: true
    //                 Layout.fillWidth: true
    //                 radius: 12
    //                 color: "#2a2a2a"
    //                 clip: true
    //
    //                 // The green fill
    //                 Rectangle {
    //                     anchors.left: parent.left
    //                     anchors.top: parent.top
    //                     anchors.bottom: parent.bottom
    //                     width: parent.width * 0.75 // 75% battery
    //                     color: "#5bf98b" // Bright green
    //                 }
    //
    //                 // Text Overlay
    //                 ColumnLayout {
    //                     anchors.right: parent.right
    //                     anchors.verticalCenter: parent.verticalCenter
    //                     anchors.rightMargin: 20
    //                     spacing: 0
    //
    //                     Text {
    //                         text: "Battery"
    //                         color: "white"
    //                         font.bold: true
    //                         font.pixelSize: 16
    //                         Layout.alignment: Qt.AlignRight
    //                     }
    //                     Text {
    //                         text: "75%" // Bind to ctx.power.batteryPercentage
    //                         color: "#dddddd"
    //                         font.pixelSize: 14
    //                         Layout.alignment: Qt.AlignRight
    //                     }
    //                 }
    //             }
    //         }
    //
    //         // --- 4. System Actions Grid ---
    //         GridLayout {
    //             columns: 3
    //             columnSpacing: 12
    //             rowSpacing: 12
    //             Layout.fillWidth: true
    //
    //             SysBtn {
    //                 iconName: "system-lock-screen"
    //                 cmd: "loginctl lock-session"
    //             }
    //             SysBtn {
    //                 iconName: "system-log-out"
    //                 cmd: "loginctl terminate-user $USER"
    //             }
    //             SysBtn {
    //                 iconName: "system-shutdown"
    //                 cmd: "systemctl poweroff"
    //             }
    //             // SysBtn { iconName: "system-reboot"; cmd: "systemctl reboot" }
    //         }
    //
    //         // Spacer
    //         Item {
    //             Layout.fillHeight: true
    //         }
    //
    //         // --- 5. Media Player ---
    //         Rectangle {
    //             Layout.fillWidth: true
    //             Layout.preferredHeight: 160
    //             radius: 12
    //             color: "#2a2a2a"
    //
    //             // Get the current player
    //             property var player: Mpris.focusedPlayer
    //
    //             RowLayout {
    //                 anchors.fill: parent
    //                 anchors.margins: 16
    //                 spacing: 16
    //
    //                 // Album Art
    //                 Rectangle {
    //                     Layout.preferredWidth: 100
    //                     Layout.preferredHeight: 100
    //                     radius: 8
    //                     color: "#000"
    //                     clip: true
    //
    //                     Image {
    //                         anchors.fill: parent
    //                         source: parent.parent.player ? parent.parent.player.metadata["mpris:artUrl"] : ""
    //                         fillMode: Image.PreserveAspectCrop
    //                     }
    //                 }
    //
    //                 // Controls & Info
    //                 ColumnLayout {
    //                     Layout.fillWidth: true
    //                     Layout.fillHeight: true
    //                     spacing: 5
    //
    //                     // Top Row: Source Icon
    //                     RowLayout {
    //                         Layout.fillWidth: true
    //                         Item {
    //                             Layout.fillWidth: true
    //                         }
    //                         Text {
    //                             text: "Spotify"
    //                             color: "#888"
    //                             font.pixelSize: 10
    //                         }
    //                         Image {
    //                             source: "image://icon/spotify"
    //                             width: 16
    //                             height: 16
    //                         }
    //                     }
    //
    //                     // Song Info
    //                     Text {
    //                         text: parent.parent.parent.player ? parent.parent.parent.player.metadata["xesam:title"] : "No Media"
    //                         color: "white"
    //                         font.bold: true
    //                         font.pixelSize: 16
    //                         elide: Text.ElideRight
    //                         Layout.fillWidth: true
    //                     }
    //                     Text {
    //                         text: parent.parent.parent.player ? parent.parent.parent.player.metadata["xesam:artist"] : ""
    //                         color: "#aaa"
    //                         font.pixelSize: 12
    //                         elide: Text.ElideRight
    //                         Layout.fillWidth: true
    //                     }
    //
    //                     Item {
    //                         Layout.fillHeight: true
    //                     } // Spacer
    //
    //                     // Controls (Prev, Play, Next)
    //                     RowLayout {
    //                         Layout.alignment: Qt.AlignHCenter
    //                         spacing: 20
    //
    //                         // Prev
    //                         Text {
    //                             text: "⏮"
    //                             color: "white"
    //                             font.pixelSize: 24
    //                             MouseArea {
    //                                 anchors.fill: parent
    //                                 onClicked: parent.parent.parent.parent.parent.player?.previous()
    //                             }
    //                         }
    //
    //                         // Play/Pause
    //                         Text {
    //                             text: (parent.parent.parent.parent.parent.player?.playbackStatus === MprisPlaybackState.Playing) ? "⏸" : "▶"
    //                             color: "white"
    //                             font.pixelSize: 32
    //                             MouseArea {
    //                                 anchors.fill: parent
    //                                 onClicked: parent.parent.parent.parent.parent.player?.playPause()
    //                             }
    //                         }
    //
    //                         // Next
    //                         Text {
    //                             text: "⏭"
    //                             color: "white"
    //                             font.pixelSize: 24
    //                             MouseArea {
    //                                 anchors.fill: parent
    //                                 onClicked: parent.parent.parent.parent.parent.player?.next()
    //                             }
    //                         }
    //                     }
    //
    //                     // Progress Bar (Mock visual for now, Mpris position is tricky in QML without specific widget)
    //                     Rectangle {
    //                         Layout.fillWidth: true
    //                         Layout.preferredHeight: 4
    //                         color: "#444"
    //                         radius: 2
    //                         Rectangle {
    //                             width: parent.width * 0.3 // Mock 30%
    //                             height: parent.height
    //                             color: "white"
    //                             radius: 2
    //                         }
    //
    //                         RowLayout {
    //                             width: parent.width
    //                             anchors.top: parent.bottom
    //                             anchors.topMargin: 4
    //                             Text {
    //                                 text: "03:11"
    //                                 color: "#666"
    //                                 font.pixelSize: 10
    //                             }
    //                             Item {
    //                                 Layout.fillWidth: true
    //                             }
    //                             Text {
    //                                 text: "04:02"
    //                                 color: "#666"
    //                                 font.pixelSize: 10
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }
    //
    // // Helper component for the big toggle buttons
    // component ToggleBtn: Rectangle {
    //     id: tBtn
    //     Layout.fillWidth: true
    //     Layout.preferredHeight: 60
    //     radius: 8
    //     color: checked ? "#5b6cf9" : "#2a2a2a" // Purple/Blue when active
    //
    //     property string title
    //     property string subtitle
    //     property string icon
    //     property bool checked: false
    //     signal clicked
    //
    //     RowLayout {
    //         anchors.fill: parent
    //         anchors.leftMargin: 15
    //         anchors.rightMargin: 15
    //         spacing: 12
    //
    //         // Icon
    //         Image {
    //             source: "image://icon/" + tBtn.icon
    //             Layout.preferredWidth: 24
    //             Layout.preferredHeight: 24
    //             fillMode: Image.PreserveAspectFit
    //             // Tint icon white if checked
    //         }
    //
    //         // Text
    //         ColumnLayout {
    //             Layout.fillWidth: true
    //             spacing: 0
    //             Text {
    //                 text: tBtn.title
    //                 color: "white"
    //                 font.bold: true
    //                 font.pixelSize: 14
    //             }
    //             Text {
    //                 text: tBtn.subtitle
    //                 color: "#dddddd"
    //                 font.pixelSize: 11
    //                 visible: text !== ""
    //             }
    //         }
    //
    //         // Arrow / Chevron
    //         Text {
    //             text: "›"
    //             color: "white"
    //             font.pixelSize: 24
    //             opacity: 0.5
    //         }
    //     }
    //     MouseArea {
    //         anchors.fill: parent
    //         onClicked: tBtn.clicked()
    //     }
    // }
    //
    // // Helper for sliders
    // component CustomSlider: ColumnLayout {
    //     property string label
    //     property string statusText
    //     property alias value: sliderControl.value
    //
    //     spacing: 5
    //
    //     RowLayout {
    //         Layout.fillWidth: true
    //         Text {
    //             text: label
    //             color: "white"
    //             font.bold: true
    //             font.pixelSize: 14
    //         }
    //         Item {
    //             Layout.fillWidth: true
    //         } // spacer
    //         Text {
    //             text: statusText
    //             color: "#999999"
    //             font.pixelSize: 12
    //         }
    //     }
    //
    //     Slider {
    //         id: sliderControl
    //         Layout.fillWidth: true
    //         from: 0
    //         to: 100
    //         value: 50
    //
    //         background: Rectangle {
    //             x: sliderControl.leftPadding
    //             y: sliderControl.topPadding + sliderControl.availableHeight / 2 - height / 2
    //             implicitWidth: 200
    //             implicitHeight: 24 // Thick track like image
    //             width: sliderControl.availableWidth
    //             height: implicitHeight
    //             radius: 4
    //             color: "#333333"
    //
    //             Rectangle {
    //                 width: sliderControl.visualPosition * parent.width
    //                 height: parent.height
    //                 color: "white"
    //                 radius: 4
    //             }
    //         }
    //         handle: Rectangle {
    //             x: sliderControl.leftPadding + sliderControl.visualPosition * (sliderControl.availableWidth - width)
    //             y: sliderControl.topPadding + sliderControl.availableHeight / 2 - height / 2
    //             width: 4 // Thin handle
    //             height: 24
    //             color: "#dddddd"
    //             radius: 2
    //         }
    //     }
    // }
    //
    // component SysBtn: Rectangle {
    //     Layout.fillWidth: true
    //     Layout.preferredHeight: 80
    //     radius: 12
    //     color: "#2a2a2a"
    //     border.color: hover.containsMouse ? "#555555" : "#333333"
    //
    //     property string iconName
    //     property string cmd: ""
    //
    //     Image {
    //         source: "image://icon/" + parent.iconName
    //         anchors.centerIn: parent
    //         width: 32
    //         height: 32
    //     }
    //
    //     MouseArea {
    //         id: hover
    //         anchors.fill: parent
    //         hoverEnabled: true
    //         onClicked: if (parent.cmd)
    //             Quickshell.execDetached(parent.cmd)
    //     }
    // }
}
