#!/usr/bin/env python3
import json
import subprocess
import sys
import time

history = {}
DEDUP_INTERVAL = 1.5  # seconds


def should_emit(key):
    now = time.time()
    if key in history and (now - history[key]) < DEDUP_INTERVAL:
        return False
    history[key] = now
    return True


def emit(icon_key, title, subtitle):
    payload = {"icon": icon_key, "title": title, "subtitle": subtitle}
    print(json.dumps(payload), flush=True)


def process_block(props):
    action = props.get("ACTION", "").lower()
    subsystem = props.get("SUBSYSTEM", "")
    devtype = props.get("DEVTYPE", "")
    devname = props.get("DEVNAME", "")

    # 1 - Power Supply / Charging Cable
    if subsystem == "power_supply":
        ps_type = props.get("POWER_SUPPLY_TYPE", "")
        ps_name = props.get("POWER_SUPPLY_NAME", "")
        ps_online = props.get("POWER_SUPPLY_ONLINE", "")
        ps_status = props.get("POWER_SUPPLY_STATUS", "")

        is_ac = (
            ps_type in ["Mains", "USB", "USB_C", "AC"]
            or "AC" in ps_name.upper()
            or "ADP" in ps_name.upper()
            or ps_name == "AC"
        )
        if is_ac:
            if ps_online == "1" or (action == "add" and ps_online != "0"):
                if should_emit(("power", "connected")):
                    emit("zap", "Charger Plugged In", "AC Power connected")
            elif (ps_online == "0" or action == "remove") and should_emit(
                ("power", "disconnected")
            ):
                emit("zap", "Charger Unplugged", "Running on battery")
        elif ps_status:
            if ps_status == "Charging":
                if should_emit(("power", "charging")):
                    emit("zap", "Charger Plugged In", "Battery is charging")
            elif (ps_status == "Discharging" and action == "change") and should_emit(
                ("power", "discharging")
            ):
                emit("zap", "Charger Unplugged", "Running on battery")
        return

    # 2 - Block Devices (Disks / USB Flash Drives / SD Cards)
    if subsystem == "block":
        if devname.startswith(
            ("/dev/loop", "/dev/ram", "/dev/zram", "/dev/dm-", "/dev/sr")
        ):
            return

        id_bus = props.get("ID_BUS", "")
        id_model = props.get("ID_MODEL", "").replace("_", " ")
        id_label = props.get("ID_FS_LABEL", "")
        device_name = (
            id_label
            or id_model
            or (devname.split("/")[-1] if devname else "Storage Device")
        )

        if action == "add" and (id_bus == "usb" or devtype in ["disk", "partition"]):
            if should_emit(("disk", device_name, "add")):
                emit(
                    "hardDrive",
                    "Disk Connected",
                    f"{device_name} ({devname})" if devname else device_name,
                )
        elif (
            action == "remove" and (id_bus == "usb" or devtype in ["disk", "partition"])
        ) and should_emit(("disk", device_name, "remove")):
            emit(
                "hardDrive",
                "Disk Disconnected",
                f"{device_name} ({devname})" if devname else device_name,
            )
        return

    # 3 - Input Devices (Gamepad, Keyboard, Mouse, Touchpad)
    if subsystem == "input":
        # Filter: only check /dev/input/event* nodes to avoid duplicate events from /dev/input/js* or input*
        if not (devname and "/event" in devname):
            return

        raw_name = (
            props.get("NAME", "").strip('"')
            or props.get("ID_MODEL", "").replace("_", " ")
            or "Device"
        )
        lower_name = raw_name.lower()

        # Ignore synthetic/system event switches
        if any(
            ign in lower_name
            for ign in [
                "power button",
                "video bus",
                "sleep button",
                "lid switch",
                "pc speaker",
            ]
        ):
            return

        is_joystick = props.get("ID_INPUT_JOYSTICK") == "1"
        is_keyboard = props.get("ID_INPUT_KEYBOARD") == "1"
        is_mouse = props.get("ID_INPUT_MOUSE") == "1"
        is_touchpad = props.get("ID_INPUT_TOUCHPAD") == "1"

        if is_joystick:
            if action == "add" and should_emit(("gamepad", raw_name, "add")):
                emit("gamepad", "Controller Connected", raw_name)
            elif action == "remove" and should_emit(("gamepad", raw_name, "remove")):
                emit("gamepad", "Controller Disconnected", raw_name)
        elif is_keyboard:
            if action == "add" and should_emit(("keyboard", raw_name, "add")):
                emit("keyboard", "Keyboard Connected", raw_name)
            elif action == "remove" and should_emit(("keyboard", raw_name, "remove")):
                emit("keyboard", "Keyboard Disconnected", raw_name)
        elif is_mouse or is_touchpad:
            dev_type_str = "Touchpad" if is_touchpad else "Mouse"
            if action == "add" and should_emit(("mouse", raw_name, "add")):
                emit("mouse", f"{dev_type_str} Connected", raw_name)
            elif action == "remove" and should_emit(("mouse", raw_name, "remove")):
                emit("mouse", f"{dev_type_str} Disconnected", raw_name)
        return

    # 4 - Generic USB Peripherals
    if subsystem == "usb" and devtype == "usb_device":
        model = (
            props.get("ID_MODEL", "").replace("_", " ")
            or props.get("ID_VENDOR", "").replace("_", " ")
            or "USB Device"
        )
        if any(
            ignore in model.lower()
            for ignore in ["root hub", "host controller", "xhci", "ehci"]
        ):
            return
        if action == "add" and should_emit(("usb", model, "add")):
            emit("usb", "Peripheral Connected", model)
        elif action == "remove" and should_emit(("usb", model, "remove")):
            emit("usb", "Peripheral Disconnected", model)


def main():
    cmd = ["udevadm", "monitor", "--udev", "--property"]
    try:
        proc = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
        )
    except Exception as e:  # noqa: BLE001
        sys.stderr.write(f"Failed to run udevadm: {e}\n")
        sys.exit(1)

    current_block = {}
    if proc.stdout is None:
        return
    for line in proc.stdout:
        line = line.strip()
        if not line:
            if current_block:
                process_block(current_block)
                current_block = {}
        elif "=" in line:
            parts = line.split("=", 1)
            current_block[parts[0]] = parts[1]


if __name__ == "__main__":
    main()
