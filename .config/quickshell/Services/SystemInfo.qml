import QtQuick
import Quickshell.Io

Item {
    id: root

    property string username: "User"
    property string uptime: "..."
    property string avatar: Qt.resolvedUrl(`file:///home/${username}/.face.png`)

    Process {
        id: whoamiProc
        running: true
        command: ["whoami"]
        stdout: SplitParser {
            onRead: data => root.username = data.trim()
        }
    }

    Process {
        id: uptimeProc
        running: true
        command: ["uptime", "-p"]
        stdout: SplitParser {
            onRead: data => root.uptime = data.trim().replace("up ", "")
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            uptimeProc.running = true;
        }
    }
}
