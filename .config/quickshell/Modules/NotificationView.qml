pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

import "../Core"
import "../Components"
import "../Assets"

Rectangle {
    id: root

    required property Colors colors
    required property Context context
    signal closed

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.preferredHeight: 400
    Layout.minimumHeight: 300

    radius: 8
    border.color: root.colors.border
    border.width: 2
    color: root.colors.contrast

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: "Notifications"
                color: root.colors.fg
                font.family: root.colors.fontFamily
                font.bold: true
                font.pixelSize: 20
                horizontalAlignment: Text.AlignLeft
            }

            Rectangle {
                visible: root.context.nsTracked.count > 0
                implicitWidth: 30
                implicitHeight: 30
                radius: 4
                color: clearMouse.containsMouse ? root.colors.contrast : "transparent"

                scale: clearMouse.pressed ? 0.9 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
                }

                CImage {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    iconSource: Icons.clean
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.context.notifier.dismissAll()
                }
            }

            Rectangle {
                width: 30
                height: 30
                radius: 4
                color: dndMouse.containsMouse ? root.colors.contrast : "transparent"

                scale: dndMouse.pressed ? 0.9 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
                }

                CImage {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    iconSource: root.context.dnd ? Icons.bellOff : Icons.bell
                    coloring: root.context.dnd ? root.colors.red : root.colors.fg
                }

                MouseArea {
                    id: dndMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.context.dnd = !root.context.dnd
                }
            }
        }

        Text {
            visible: root.context.nsTracked.count === 0
            text: "No notifications"
            color: root.colors.muted
            font.family: root.colors.fontFamily
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
        }

        ListView {
            visible: root.context.nsTracked.count > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 15
            model: root.context.notifier.groups

            delegate: ColumnLayout {
                id: groupDelegate
                width: ListView.view.width
                spacing: 8

                required property string appName
                required property string appIcon
                required property var notifications // This is the ListModel for the group

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Image {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        source: Quickshell.iconPath(groupDelegate.appIcon, "application-x-executable")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: groupDelegate.appName
                        color: root.colors.fg
                        font.family: root.colors.fontFamily
                        font.bold: true
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        width: 24
                        height: 24
                        radius: 4
                        color: groupClearMouse.containsMouse ? root.colors.contrast : "transparent"

                        CImage {
                            anchors.centerIn: parent
                            width: 14
                            height: 14
                            iconSource: Icons.clean
                        }

                        MouseArea {
                            id: groupClearMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.context.notifier.dismissGroup(groupDelegate.appName)
                        }
                    }
                }

                Repeater {
                    model: groupDelegate.notifications
                    delegate: Rectangle {
                        id: notifDelegate
                        required property Notification notification

                        width: groupDelegate.width
                        implicitHeight: contentColumn.implicitHeight + 20
                        color: root.colors.contrast
                        radius: 12
                        border.width: 2
                        border.color: root.colors.border

                        scale: notiMouse.pressed ? 0.98 : 1.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                            }
                        }

                        MouseArea {
                            id: notiMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: () => {
                                if (notification.actions.length === 1) {
                                    notification.actions[0].invoke();
                                    root.closed();
                                }
                            }
                        }

                        ColumnLayout {
                            id: contentColumn
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                // App icon is already in header, so maybe use notification specific icon here if different
                                Image {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    Layout.alignment: Qt.AlignTop
                                    source: notification.image.length > 0 ? notification.image : Quickshell.iconPath(notification.appIcon || notification.desktopEntry || notification.appName || "application-x-executable", "application-x-executable")
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    mipmap: true
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: notification.summary
                                        color: root.colors.fg
                                        font.bold: true
                                        font.family: root.colors.fontFamily
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: notification.body
                                        color: Qt.lighter(root.colors.fg, 1.5)
                                        font.family: root.colors.fontFamily
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 10
                                    }
                                }

                                Text {
                                    text: root.context.timeAgo(root.context.notificationTimes[notification.id])
                                    color: Qt.lighter(root.colors.fg, 1.5)
                                    font.family: root.colors.fontFamily
                                    font.pixelSize: 11
                                    Layout.alignment: Qt.AlignTop
                                }

                                CImage {
                                    iconSource: Icons.close
                                    width: 16
                                    height: 16
                                    Layout.alignment: Qt.AlignTop

                                    scale: dismissButton.pressed ? 0.9 : 1.0
                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 100
                                        }
                                    }

                                    MouseArea {
                                        id: dismissButton
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: notification.dismiss()
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                visible: notification.actions.length > 1
                                spacing: 10

                                Repeater {
                                    model: notification.actions
                                    delegate: Rectangle {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        height: 30
                                        color: actMouse.containsMouse ? Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.1) : "transparent"
                                        radius: 8
                                        border.width: 2
                                        border.color: root.colors.border

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 150
                                            }
                                        }

                                        Text {
                                            anchors {
                                                fill: parent
                                                leftMargin: 8
                                                rightMargin: 8
                                            }
                                            text: modelData.text
                                            color: root.colors.fg
                                            font.family: root.colors.fontFamily
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        MouseArea {
                                            id: actMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
