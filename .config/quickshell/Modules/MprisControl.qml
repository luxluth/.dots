import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Mpris
import "../Assets/"
import "../Components/"
import "../Core"

ClippingRectangle {
    id: mprisRoot

    required property Colors colors
    required property Context context

    radius: colors.radiusMedium
    color: colors.contrast
    clip: true

    property var player: context.media.activePlayer

    property string localArtPath: ""
    property string lastDownloadedUrl: ""

    onPlayerChanged: updateArtSource()

    Connections {
        target: mprisRoot.player ? mprisRoot.player : null
        ignoreUnknownSignals: true
        function onTrackArtUrlChanged() {
            mprisRoot.updateArtSource();
        }
    }

    Component.onCompleted: updateArtSource()

    Process {
        id: artDownloader
        running: false

        property string destPath: ""

        function download(url, dest) {
            if (running) {
                running = false;
            }
            destPath = dest;
            command = ["sh", "-c", "rm -f /tmp/mpris_art_*.png; curl -s -L -o " + dest + " " + url];
            running = true;
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                mprisRoot.localArtPath = "file://" + destPath;
            }
        }
    }

    function updateArtSource() {
        if (!mprisRoot.player || !mprisRoot.player.trackArtUrl) {
            mprisRoot.localArtPath = "";
            mprisRoot.lastDownloadedUrl = "";
            return;
        }

        let url = mprisRoot.player.trackArtUrl;
        if (url.indexOf("http://") === 0 || url.indexOf("https://") === 0) {
            if (url === mprisRoot.lastDownloadedUrl) {
                return;
            }
            mprisRoot.lastDownloadedUrl = url;

            let timestamp = new Date().getTime();
            let dest = "/tmp/mpris_art_" + timestamp + ".png";
            artDownloader.download(url, dest);
        } else {
            mprisRoot.localArtPath = url;
            mprisRoot.lastDownloadedUrl = "";
        }
    }

    function switchToNextPlayer() {
        const list = mprisRoot.context.media.players;
        if (list.length <= 1)
            return;
        let idx = list.indexOf(mprisRoot.player);
        if (idx === -1) {
            mprisRoot.context.media.activePlayer = list[0];
        } else {
            mprisRoot.context.media.activePlayer = list[(idx + 1) % list.length];
        }
    }

    function switchToPreviousPlayer() {
        const list = mprisRoot.context.media.players;
        if (list.length <= 1)
            return;
        let idx = list.indexOf(mprisRoot.player);
        if (idx === -1) {
            mprisRoot.context.media.activePlayer = list[list.length - 1];
        } else {
            mprisRoot.context.media.activePlayer = list[(idx - 1 + list.length) % list.length];
        }
    }

    property color extractedBgColor: mprisRoot.colors.bg
    property color extractedAccentColor: mprisRoot.colors.accent

    readonly property bool isLive: mprisRoot.player && (mprisRoot.player.length <= 0 || mprisRoot.player.length > 86400 || !isFinite(mprisRoot.player.length))

    // No Player State
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12
        visible: !mprisRoot.player

        CImage {
            Layout.alignment: Qt.AlignHCenter
            iconSource: Icons.play
            width: 32
            height: 32
            coloring: mprisRoot.colors.transparentFg
        }

        Text {
            text: "No Media Playing"
            color: mprisRoot.colors.transparentFg
            font.family: mprisRoot.colors.fontFamily
            font.pixelSize: 14
            font.bold: true
        }
    }

    // Active Player UI
    Item {
        anchors.fill: parent
        visible: !!mprisRoot.player
        anchors.margins: 16

        // Trackpad 2-finger horizontal scroll/swipe & single-finger drag detector
        MouseArea {
            id: swipeDetector
            anchors.fill: parent
            z: -1

            property real startX: 0
            property real startY: 0
            readonly property real minSwipeDistance: 40
            readonly property real maxVerticalDeviation: 40
            property real lastScrollTime: 0

            onPressed: mouse => {
                startX = mouse.x;
                startY = mouse.y;
            }

            onReleased: mouse => {
                let deltaX = mouse.x - startX;
                let deltaY = mouse.y - startY;

                if (Math.abs(deltaY) < maxVerticalDeviation) {
                    if (deltaX > minSwipeDistance) {
                        mprisRoot.switchToPreviousPlayer();
                    } else if (deltaX < -minSwipeDistance) {
                        mprisRoot.switchToNextPlayer();
                    }
                }
            }

            onWheel: wheel => {
                if (wheel.angleDelta.x !== 0) {
                    let now = new Date().getTime();
                    if (now - lastScrollTime > 300) {
                        lastScrollTime = now;
                        if (wheel.angleDelta.x > 0) {
                            mprisRoot.switchToPreviousPlayer();
                        } else if (wheel.angleDelta.x < 0) {
                            mprisRoot.switchToNextPlayer();
                        }
                    }
                }
            }
        }

        // Touchscreen 2-finger horizontal swipe detector
        MultiPointTouchArea {
            id: touchDetector
            anchors.fill: parent
            z: -1

            property real startX: 0
            property real startY: 0
            property bool gestureActive: false
            readonly property real minSwipeDistance: 40
            readonly property real maxVerticalDeviation: 40

            onPressed: touchPoints => {
                if (touchPoints.length === 2) {
                    startX = (touchPoints[0].x + touchPoints[1].x) / 2;
                    startY = (touchPoints[0].y + touchPoints[1].y) / 2;
                    gestureActive = true;
                } else {
                    gestureActive = false;
                }
            }

            onReleased: touchPoints => {
                if (gestureActive && touchPoints.length === 2) {
                    let currentX = (touchPoints[0].x + touchPoints[1].x) / 2;
                    let currentY = (touchPoints[0].y + touchPoints[1].y) / 2;
                    let deltaX = currentX - startX;
                    let deltaY = currentY - startY;

                    if (Math.abs(deltaY) < maxVerticalDeviation) {
                        if (deltaX > minSwipeDistance) {
                            mprisRoot.switchToPreviousPlayer();
                        } else if (deltaX < -minSwipeDistance) {
                            mprisRoot.switchToNextPlayer();
                        }
                    }
                }
                gestureActive = false;
            }
        }

        // Position Timer to update progress bar smoothly
        Timer {
            id: progressUpdateTimer
            running: parent.visible && mprisRoot.context.media.activePlayer && mprisRoot.context.media.activePlayer.playbackState === MprisPlaybackState.Playing
            interval: 500
            repeat: true
            onTriggered: {
                if (mprisRoot.context.media.activePlayer) {
                    mprisRoot.context.media.activePlayer.positionChanged();
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            // Minimal Carousel Indicator (visible only if there are multiple active players)
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: mprisRoot.context.media.players.length > 1
                Layout.alignment: Qt.AlignHCenter

                Item {
                    Layout.fillWidth: true
                } // Left spacer

                Repeater {
                    model: mprisRoot.context.media.players
                    delegate: Rectangle {
                        id: dot
                        required property var modelData

                        width: mprisRoot.player === modelData ? 14 : 6
                        height: 6
                        radius: 3

                        Layout.preferredWidth: width
                        Layout.preferredHeight: height

                        color: mprisRoot.player === modelData ? mprisRoot.extractedAccentColor : mprisRoot.colors.border

                        Behavior on width {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mprisRoot.context.media.activePlayer = dot.modelData
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                } // Right spacer
            }

            Item {
                Layout.fillHeight: true
            } // Top Spacer

            // Track Info Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                // Album Art
                ClippingRectangle {
                    width: 64
                    height: 64
                    radius: mprisRoot.colors.radiusCompact
                    color: mprisRoot.colors.contrast
                    antialiasing: true

                    Image {
                        anchors.fill: parent
                        source: (mprisRoot.player && mprisRoot.localArtPath) ? mprisRoot.localArtPath : ""
                        fillMode: Image.PreserveAspectCrop
                        smooth: true

                        // Fallback icon if no album art
                        CImage {
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            iconSource: Icons.audioLines
                            coloring: mprisRoot.colors.transparentFg
                            visible: parent.source == ""
                        }
                    }

                    // Border Overlay (drawn on top of the image to ensure visibility)
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: mprisRoot.colors.border
                        border.width: 2
                        radius: mprisRoot.colors.radiusCompact
                    }
                }

                // Metadata Column (Title, Artist)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: (mprisRoot.player && mprisRoot.player.trackTitle) ? mprisRoot.player.trackTitle : "Unknown Title"
                        color: mprisRoot.colors.fg
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font {
                            family: mprisRoot.colors.fontFamily
                            pixelSize: 15
                            bold: true
                        }
                    }

                    Text {
                        text: (mprisRoot.player && mprisRoot.player.trackArtist) ? mprisRoot.player.trackArtist : "Unknown Artist"
                        color: mprisRoot.colors.transparentFg
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font {
                            family: mprisRoot.colors.fontFamily
                            pixelSize: 13
                        }
                    }
                }
            }

            // Playback Controls Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Item {
                    Layout.fillWidth: true
                } // Left Center Spacer

                // Previous
                Rectangle {
                    visible: mprisRoot.player && mprisRoot.player.canGoPrevious
                    width: 36
                    height: 36
                    radius: mprisRoot.colors.radiusCompact
                    color: prevMouse.containsMouse ? Qt.rgba(mprisRoot.extractedAccentColor.r, mprisRoot.extractedAccentColor.g, mprisRoot.extractedAccentColor.b, 0.15) : mprisRoot.colors.contrast
                    border.color: prevMouse.containsMouse ? mprisRoot.extractedAccentColor : mprisRoot.colors.border
                    border.width: 2

                    scale: prevMouse.pressed ? 0.95 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }
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

                    CImage {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        iconSource: Icons.forward
                        coloring: prevMouse.containsMouse ? mprisRoot.extractedAccentColor : mprisRoot.colors.fg
                        rotation: 180
                        Behavior on coloring {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (mprisRoot.player) {
                                mprisRoot.player.previous();
                            }
                        }
                    }
                }

                // Play/Pause
                Rectangle {
                    width: 44
                    height: 44
                    radius: mprisRoot.colors.radiusCompact
                    color: playMouse.containsMouse ? mprisRoot.extractedAccentColor : Qt.rgba(mprisRoot.extractedAccentColor.r, mprisRoot.extractedAccentColor.g, mprisRoot.extractedAccentColor.b, 0.2)
                    border.color: mprisRoot.extractedAccentColor
                    border.width: 2

                    scale: playMouse.pressed ? 0.95 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    CImage {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        iconSource: (mprisRoot.player && mprisRoot.player.playbackState === MprisPlaybackState.Playing) ? Icons.pause : Icons.play
                        coloring: playMouse.containsMouse ? mprisRoot.colors.bg : mprisRoot.extractedAccentColor
                        Behavior on coloring {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (mprisRoot.player) {
                                if (mprisRoot.player.playbackState === MprisPlaybackState.Playing) {
                                    mprisRoot.player.pause();
                                } else {
                                    mprisRoot.player.play();
                                }
                            }
                        }
                    }
                }

                // Next
                Rectangle {
                    visible: mprisRoot.player && mprisRoot.player.canGoNext
                    width: 36
                    height: 36
                    radius: mprisRoot.colors.radiusCompact
                    color: nextMouse.containsMouse ? Qt.rgba(mprisRoot.extractedAccentColor.r, mprisRoot.extractedAccentColor.g, mprisRoot.extractedAccentColor.b, 0.15) : mprisRoot.colors.contrast
                    border.color: nextMouse.containsMouse ? mprisRoot.extractedAccentColor : mprisRoot.colors.border
                    border.width: 2

                    scale: nextMouse.pressed ? 0.95 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }
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

                    CImage {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        iconSource: Icons.forward
                        coloring: nextMouse.containsMouse ? mprisRoot.extractedAccentColor : mprisRoot.colors.fg
                        Behavior on coloring {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (mprisRoot.player) {
                                mprisRoot.player.next();
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                } // Right Center Spacer
            }

            // Progress Bar / Slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // Time Labels
                RowLayout {
                    Layout.fillWidth: true
                    visible: !mprisRoot.isLive

                    Text {
                        text: mprisRoot.player ? mprisRoot.context.media.formatTime(mprisRoot.player.position) : "0:00"
                        color: Qt.rgba(mprisRoot.colors.fg.r, mprisRoot.colors.fg.g, mprisRoot.colors.fg.b, 0.8)
                        font {
                            family: mprisRoot.colors.fontFamily
                            pixelSize: 11
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: (mprisRoot.player && mprisRoot.player.length > 0) ? "-" + mprisRoot.context.media.formatTime(Math.max(0, mprisRoot.player.length - mprisRoot.player.position)) : "0:00"
                        color: Qt.rgba(mprisRoot.colors.fg.r, mprisRoot.colors.fg.g, mprisRoot.colors.fg.b, 0.8)
                        font {
                            family: mprisRoot.colors.fontFamily
                            pixelSize: 11
                        }
                    }
                }

                // Track Slider (Interactive Seeking - Thinner unified SliderControl style)
                Item {
                    id: progressSlider
                    Layout.fillWidth: true
                    height: 20
                    visible: !mprisRoot.isLive

                    property real value: 0
                    readonly property alias pressed: sliderMouse.pressed

                    Binding {
                        target: progressSlider
                        property: "value"
                        value: (mprisRoot.player && mprisRoot.player.length > 0) ? Math.max(0, Math.min(1, mprisRoot.player.position / mprisRoot.player.length)) : 0
                        when: mprisRoot.player !== null && !progressSlider.pressed
                    }

                    // Background Track
                    ClippingRectangle {
                        id: track
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 8
                        radius: mprisRoot.colors.radiusSmall
                        color: mprisRoot.colors.contrast
                        border.color: Qt.rgba(mprisRoot.colors.border.r, mprisRoot.colors.border.g, mprisRoot.colors.border.b, 0.4)
                        border.width: 1
                        antialiasing: true

                        // Filled Track
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: parent.height
                            width: parent.width * progressSlider.value
                            color: mprisRoot.extractedAccentColor
                            Behavior on color {
                                ColorAnimation {
                                    duration: 300
                                }
                            }
                        }
                    }

                    // Thinner handle matching SliderControl style
                    Rectangle {
                        id: handle
                        anchors.verticalCenter: parent.verticalCenter
                        x: (track.width * progressSlider.value) - (width / 2)
                        width: 6
                        height: track.height + 6
                        radius: mprisRoot.colors.radiusSmall
                        color: mprisRoot.extractedAccentColor
                        border.color: Qt.rgba(mprisRoot.colors.border.r, mprisRoot.colors.border.g, mprisRoot.colors.border.b, 0.4)
                        border.width: 1

                        scale: sliderMouse.pressed ? 0.92 : 1.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 300
                            }
                        }
                    }

                    MouseArea {
                        id: sliderMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onPressed: mouse => seekTo(mouse.x)
                        onPositionChanged: mouse => {
                            if (pressed)
                                seekTo(mouse.x);
                        }

                        function seekTo(mouseX) {
                            if (mprisRoot.player && mprisRoot.player.length > 0) {
                                const ratio = Math.max(0, Math.min(1, mouseX / width));
                                progressSlider.value = ratio;
                                mprisRoot.player.position = ratio * mprisRoot.player.length;
                            }
                        }
                    }
                }

                // Live Stream Indicator
                RowLayout {
                    Layout.fillWidth: true
                    visible: mprisRoot.isLive
                    spacing: 8
                    Layout.alignment: Qt.AlignHCenter

                    Item {
                        Layout.fillWidth: true
                    } // Left spacer

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: mprisRoot.colors.red
                        Layout.alignment: Qt.AlignVCenter
                        SequentialAnimation on opacity {
                            running: mprisRoot.isLive && mprisRoot.context.media.activePlayer && mprisRoot.context.media.activePlayer.playbackState === MprisPlaybackState.Playing
                            loops: Animation.Infinite
                            NumberAnimation {
                                from: 0.3
                                to: 1.0
                                duration: 800
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                from: 1.0
                                to: 0.3
                                duration: 800
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                    Text {
                        text: "IN LIVE"
                        color: mprisRoot.colors.red
                        font {
                            family: mprisRoot.colors.fontFamily
                            pixelSize: 12
                            bold: true
                            letterSpacing: 2
                        }
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    } // Right spacer
                }
            }

            Item {
                Layout.fillHeight: true
            } // Bottom Spacer
        }
    }

    // Border Overlay (drawn on top of all children to guarantee visibility)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: mprisRoot.colors.border
        border.width: 2
        radius: mprisRoot.radius
    }
}
