import QtQuick
import Quickshell.Io
import "../Assets/"

Item {
    id: root

    property string username: ""
    property string uptime: "..."
    property string avatar: username.length > 0 ? Qt.resolvedUrl(`file:///home/${username}/.face.png`) : Icons.close

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
            onRead: data => {
                root.uptime = data.trim().replace("up ", "").replace(/\s/, "").replace(/days,|day,/, "d").replace(/\s/, "").replace(/hours,|hour,/, "h").replace(/\s/, "").replace(/minutes|minute/, "m").replace(/\s/, "").replace(/\s/, "");
            }
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
