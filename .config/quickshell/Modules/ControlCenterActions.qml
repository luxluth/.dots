import QtQuick
import "../Assets"
import "../Core"

QtObject {
    id: root
    required property Context context
    required property Colors colors

    property var actions: [
        {
            active: root.context.airplaneMode,
            icon: Icons.plane,
            action: (item, proc, wasActive) => {
                if (wasActive) {
                    root.context.network.wifiEnabled = true;
                    root.context.blt.adapter.enabled = true;
                } else {
                    root.context.network.wifiEnabled = false;
                    root.context.blt.adapter.enabled = false;
                }
            }
        },
        {
            active: false,
            icon: Icons.bellOff,
            action: (item, proc) => {}
        },
        {
            active: false,
            icon: Icons.logOut,
            action: (item, proc) => {
                context.popup("Are you sure you want to logout ?", [
                    {
                        id: "cancel",
                        text: "Cancel",
                        _signal: () => {
                            proc.command = ["fish", "-c", "qs ipc call cc toggle"];
                            proc.running = true;
                        }
                    },
                    {
                        id: "logout",
                        text: "Logout",
                        _signal: () => {
                            proc.command = ["fish", "-c", "loginctl terminate-user $USER"];
                            proc.running = true;
                        }
                    },
                ], "cancel");
            }
        },
        {
            active: false,
            icon: Icons.rotateCCW,
            action: (item, proc) => {
                context.popup("Are you sure you want to reboot?", [
                    {
                        id: "cancel",
                        text: "Cancel",
                        _signal: () => {
                            proc.command = ["fish", "-c", "qs ipc call cc toggle"];
                            proc.running = true;
                        }
                    },
                    {
                        id: "reboot",
                        text: "Reboot",
                        _signal: () => {
                            proc.command = ["systemctl", "reboot"];
                            proc.running = true;
                        }
                    },
                    {
                        id: "frimware",
                        text: "Firmware setup",
                        _signal: () => {
                            proc.command = ["systemctl", "reboot", "--firmware-setup"];
                            proc.running = true;
                        }
                    }
                ], "cancel");
            }
        },
        {
            active: false,
            icon: Icons.lock,
            action: (item, proc) => {
                proc.command = ["fish", "-c", "hyprlock"];
                proc.running = true;
            }
        },
        {
            active: false,
            icon: Icons.power,
            color: root.colors.red,
            action: (item, proc) => {
                context.popup("Are you sure you want to shutdown the machine ?", [
                    {
                        id: "cancel",
                        text: "Cancel",
                        _signal: () => {
                            proc.command = ["fish", "-c", "qs ipc call cc toggle"];
                            proc.running = true;
                        }
                    },
                    {
                        id: "hibernate",
                        text: "Hibernate",
                        _signal: () => {
                            proc.command = ["systemctl", "hibernate"];
                            proc.running = true;
                        }
                    },
                    {
                        id: "shutdown",
                        text: "Shutdown",
                        _signal: () => {
                            proc.command = ["systemctl", "poweroff"];
                            proc.running = true;
                        }
                    },
                ], "cancel");
            }
        },
    ]
}
