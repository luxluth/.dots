import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Item {
    id: compositor

    property list<string> focused: ["", ""] // class, windowttle
    property var focusedWorkspace: ({})
    property var workspaces: []
    property var workspaceIds: []
    property var workspaceById: ({})

    property bool firstRun: true

    function gotoWorkspace(wid) {
        Hyprland.dispatch(`workspace ${wid}`);
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (compositor.firstRun) {
                getWorkspaces.running = true;
                focusedWorkspace.running = true;
                setFocused.running = true;
                compositor.firstRun = false;
            }
            if (event.name == "activewindow") {
                compositor.focused = event.parse(2);
            } else if (event.name == "workspace") {
                getWorkspaces.running = true;
                focusedWorkspace.running = true;
            }
        }
    }

    Process {
        id: getWorkspaces
        command: ["hyprctl", "workspaces", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let rawWorkspaces = JSON.parse(this.text);
                    rawWorkspaces.sort((a, b) => a.id - b.id);

                    compositor.workspaces = rawWorkspaces;

                    let map = {};
                    for (let ws of compositor.workspaces)
                        map[ws.id] = ws;
                    compositor.workspaceById = map;
                    compositor.workspaceIds = compositor.workspaces.map(ws => ws.id);
                } catch (e) {
                    console.error("Failed to parse workspaces:", e);
                }
            }
        }
    }

    Process {
        id: focusedWorkspace
        command: ["hyprctl", "activeworkspace", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                compositor.focusedWorkspace = JSON.parse(this.text);
            }
        }
    }

    Process {
        id: setFocused
        command: ["hyprctl", "activewindow", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                const data = JSON.parse(this.text);
                if (data.class) {
                    compositor.focused = [data.class, data.title];
                }
            }
        }
    }
}
