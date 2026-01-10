import Quickshell.Services.UPower
import QtQuick

Item {
    id: power
    property UPowerDevice battery: UPower.devices.values[0]
    property var batteryPercentage: `${(battery.percentage * 100).toFixed(0)}% ${getIcon()}`
    property var batteryCharging: battery.state == UPowerDeviceState.Charging
    property var batteryLow: battery.percentage <= 0.2
    property var batteryAlternateText: getAlternateText()

    function getIcon(): string {
        const icons = ["", "", "", "", ""];
        const iconsIdx = Math.floor(battery.percentage * 4);
        return batteryCharging ? "" : icons[iconsIdx];
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
}
