pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQml
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

import "../Components"
import "../Core"
import "../Assets"

Item {
    id: root
    required property Colors colors
    required property Context context

    property Notification activeNotification: null
    property bool shouldShow: false

    signal notificationClosed(Notification notification)
    signal notificationDisplayed(Notification notification)

    Connections {
        target: root.context
        function onNotificationReceived(n) {
            if (root.context.notificationPopupVisible || root.context.dnd)
                return;

            root.activeNotification = n;
            root.shouldShow = true;
        }
    }

    LazyLoader {
        active: root.shouldShow && root.activeNotification !== null

        PanelWindow {
            id: window
            property Notification notification: root.activeNotification

            screen: root.context.window ? root.context.window.screen : Quickshell.screens[0]

            anchors {
                top: true
            }
            margins.top: 50

            implicitWidth: 320
            implicitHeight: container.implicitHeight

            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs-notification"
            WlrLayershell.exclusiveZone: -1

            Item {
                id: container
                width: parent.width
                implicitHeight: content.implicitHeight + 20

                property bool closing: false
                property bool expanded: notification.actions.length >= 2

                Connections {
                    target: window
                    function onNotificationChanged() {
                        container.closing = false;
                        container.expanded = window.notification.actions.length >= 2;
                        autoCloseTimer.restart();
                        if (exitAnim.running) {
                            exitAnim.stop();
                            container.scale = 1.0;
                            container.opacity = 1.0;
                        }
                    }
                }

                opacity: 0
                scale: 0.9
                transformOrigin: Item.TopRight

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
                    onFinished: {
                        root.notificationClosed(window.notification);
                        root.shouldShow = false;
                    }
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

                function close() {
                    if (container.closing)
                        return;
                    container.closing = true;
                    exitAnim.start();
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: () => {
                        if (notification.actions.length == 1) {
                            notification.actions[0].invoke();
                        }
                    }
                }

                Timer {
                    id: autoCloseTimer
                    interval: (notification && notification.expireTimeout > 0) ? notification.expireTimeout : 4000
                    running: !mouseArea.containsMouse
                    onTriggered: {
                        if (notification) {
                            root.notificationDisplayed(notification);
                            // notification.expire();
                        }
                        container.close();
                    }
                }

                Connections {
                    target: notification
                    function onClosed() {
                        container.close();
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.9)
                    border.width: 1
                    border.color: Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.1)

                    ColumnLayout {
                        id: content
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 10
                            leftMargin: 15
                            rightMargin: 15
                        }
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Image {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                Layout.alignment: container.expanded ? Qt.AlignTop : Qt.AlignVCenter
                                source: Quickshell.iconPath(window.notification.appIcon || window.notification.image || window.notification.appName || "application-x-executable", "application-x-executable")
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                id: notifText
                                Layout.fillWidth: true
                                Layout.alignment: container.expanded ? Qt.AlignTop : Qt.AlignVCenter
                                text: "<b>" + notification.summary + "</b> " + notification.body
                                textFormat: Text.StyledText
                                color: root.colors.fg
                                font.family: root.colors.fontFamily
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                wrapMode: container.expanded ? Text.WordWrap : Text.NoWrap
                                maximumLineCount: container.expanded ? 99 : 1
                            }

                            CImage {
                                iconSource: Icons.chevronRight
                                rotation: container.expanded ? 90 : 0
                                width: 16
                                height: 16
                                visible: notifText.truncated || container.expanded
                                Layout.alignment: container.expanded ? Qt.AlignTop : Qt.AlignVCenter

                                scale: expandButton.containsPress ? 0.85 : 1.0

                                Behavior on rotation {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }

                                MouseArea {
                                    id: expandButton
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: container.expanded = !container.expanded
                                }
                            }

                            CImage {
                                iconSource: Icons.close
                                width: 16
                                height: 16
                                Layout.alignment: container.expanded ? Qt.AlignTop : Qt.AlignVCenter

                                scale: closeButton.containsPress ? 0.85 : 1.0

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }

                                MouseArea {
                                    id: closeButton
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: () => {
                                        if (window.notification)
                                            window.notification.dismiss();
                                        container.close();
                                    }
                                }
                            }
                        }

                        RowLayout {
                            visible: container.expanded && notification.actions.length > 1
                            Layout.fillWidth: true
                            spacing: 10

                            Repeater {
                                model: notification.actions
                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    height: 30
                                    color: actMouse.containsMouse ? Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.1) : "transparent"
                                    radius: 12
                                    border.width: 1
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
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        id: actMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            modelData.invoke();
                                            container.close();
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
