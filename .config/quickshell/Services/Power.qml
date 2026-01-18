import Quickshell.Services.UPower
import QtQuick
import Quickshell.Io

Item {
    id: root
    property UPowerDevice battery: UPower.devices.values[0]
    property var batteryCharging: battery.state == UPowerDeviceState.Charging
    property var batteryPercentage: `${(battery.percentage * 100).toFixed(batteryCharging ? 1 : 0)}${getIcon()}`
    property var batteryLow: battery.percentage <= 0.2
    property var batteryAlternateText: getAlternateText()
    property int profile: Power.PowerProfile.Balanced

    enum PowerProfile {
        Balanced = 0,
        Performance = 1,
        PowerSaver = 2
    }

    function cycle() {
        if (profile === Power.PowerProfile.Balanced) {
            root.profile = Power.PowerProfile.Performance;
        } else if (profile === Power.PowerProfile.Performance) {
            root.profile = Power.PowerProfile.PowerSaver;
        } else if (profile === Power.PowerProfile.PowerSaver) {
            root.profile = Power.PowerProfile.Balanced;
        }
        setPowerProfile.running = true;
    }

    function profileToText(profile: int): string {
        if (profile === Power.PowerProfile.Balanced) {
            return "balanced";
        } else if (profile === Power.PowerProfile.Performance) {
            return "performance";
        } else if (profile === Power.PowerProfile.PowerSaver) {
            return "power-saver";
        }
    }

    function getIcon(): string {
        return batteryCharging ? "/100" : "";
    }

    function getAlternateText() {
        if (batteryCharging) {
            const time = secondsToFormat(battery.timeToFull);
            if (isNaN(time.seconds))
                return '...';
            return `Full in ${time.hours}h${time.minutes}m`;
        } else {
            const time = secondsToFormat(battery.timeToEmpty);
            if (isNaN(time.seconds))
                return '...';
            return `Empty in ${time.hours}h${time.minutes}m`;
        }
    }

    function secondsToFormat(secs) {
        let time = {
            seconds: 0,
            minutes: 0,
            hours: 0
        };

        time.minutes = Math.floor((secs / 60) % secs);
        time.seconds = secs - (time.minutes * 60);
        time.hours = Math.floor((time.minutes / 60) % time.minutes);
        time.minutes = time.minutes - (time.hours * 60);
        return time;
    }

    Process {
        id: getPowerProfile
        running: true
        command: ["fish", "-c", "powerprofilesctl get"]
        stdout: SplitParser {
            onRead: data => {
                let d = data.trim();
                if (d == "balanced") {
                    root.profile = Power.PowerProfile.Balanced;
                } else if (d == "power-saver") {
                    root.profile = Power.PowerProfile.PowerSaver;
                } else if (d == "performance") {
                    root.profile = Power.PowerProfile.Performance;
                }
            }
        }
    }

    Process {
        id: setPowerProfile
        command: ["fish", "-c", `powerprofilesctl set ${root.profileToText(root.profile)}`]
    }
}
