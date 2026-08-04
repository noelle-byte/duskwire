#!/usr/bin/env python3
"""State and actions for the Duskwire Eww quick-control popups."""

from __future__ import annotations

import base64
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any


def run(args: list[str], *, timeout: float = 4.0) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            args,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            timeout=timeout,
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return subprocess.CompletedProcess(args, 127, "")


def output(args: list[str], *, timeout: float = 4.0) -> str:
    return run(args, timeout=timeout).stdout.strip()


def command_exists(name: str) -> bool:
    return shutil.which(name) is not None


def token(value: str) -> str:
    return base64.urlsafe_b64encode(value.encode("utf-8")).decode("ascii").rstrip("=")


def untoken(value: str) -> str:
    value += "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value.encode("ascii")).decode("utf-8")


def emit(payload: dict[str, Any]) -> None:
    print(json.dumps(payload, ensure_ascii=False, separators=(",", ":")))


def parse_wpctl_volume(target: str) -> tuple[int, bool]:
    text = output(["wpctl", "get-volume", target])
    match = re.search(r"([0-9]+(?:\.[0-9]+)?)", text)
    volume = round(float(match.group(1)) * 100) if match else 0
    return max(0, min(volume, 150)), "MUTED" in text


def wpctl_description(target: str, fallback: str) -> str:
    text = output(["wpctl", "inspect", target])
    for key in ("node.description", "node.nick", "device.description"):
        match = re.search(rf'{re.escape(key)}\s*=\s*"([^"]+)"', text)
        if match:
            return match.group(1)
    return fallback


def pactl_json(kind: str) -> list[dict[str, Any]]:
    text = output(["pactl", "-f", "json", "list", kind], timeout=6.0)
    if not text:
        return []
    try:
        value = json.loads(text)
        return value if isinstance(value, list) else []
    except json.JSONDecodeError:
        return []


def audio_state() -> dict[str, Any]:
    sink_volume, sink_muted = parse_wpctl_volume("@DEFAULT_AUDIO_SINK@")
    source_volume, source_muted = parse_wpctl_volume("@DEFAULT_AUDIO_SOURCE@")

    default_sink = output(["pactl", "get-default-sink"])
    default_source = output(["pactl", "get-default-source"])

    sinks: list[dict[str, Any]] = []
    for item in pactl_json("sinks"):
        name = str(item.get("name", ""))
        if not name:
            continue
        description = str(item.get("description") or name)
        sinks.append(
            {
                "name": description,
                "token": token(name),
                "active": name == default_sink,
            }
        )

    sources: list[dict[str, Any]] = []
    for item in pactl_json("sources"):
        name = str(item.get("name", ""))
        if not name or name.endswith(".monitor"):
            continue
        description = str(item.get("description") or name)
        sources.append(
            {
                "name": description,
                "token": token(name),
                "active": name == default_source,
            }
        )

    media_status = output(["playerctl", "status"])
    media_available = media_status in {"Playing", "Paused"}
    title = output(["playerctl", "metadata", "--format", "{{title}}"])
    artist = output(["playerctl", "metadata", "--format", "{{artist}}"])
    player = output(["playerctl", "metadata", "--format", "{{playerName}}"])

    return {
        "volume": sink_volume,
        "muted": sink_muted,
        "output": wpctl_description("@DEFAULT_AUDIO_SINK@", "Default output"),
        "microphone_volume": source_volume,
        "microphone_muted": source_muted,
        "microphone": wpctl_description("@DEFAULT_AUDIO_SOURCE@", "Default microphone"),
        "sinks": sinks[:8],
        "sources": sources[:8],
        "media": {
            "available": media_available,
            "playing": media_status == "Playing",
            "title": title or "Nothing playing",
            "artist": artist or player or "No active media player",
        },
    }


def split_nmcli_line(line: str) -> list[str]:
    fields: list[str] = []
    current: list[str] = []
    escaped = False
    for char in line:
        if escaped:
            current.append(char)
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == ":":
            fields.append("".join(current))
            current = []
        else:
            current.append(char)
    fields.append("".join(current))
    return fields


def wifi_connections() -> dict[str, str]:
    known: dict[str, str] = {}
    text = output(["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"])
    for line in text.splitlines():
        fields = split_nmcli_line(line)
        if len(fields) < 2 or fields[-1] != "802-11-wireless":
            continue
        connection_name = ":".join(fields[:-1])
        ssid = output(["nmcli", "-g", "802-11-wireless.ssid", "connection", "show", connection_name])
        if ssid:
            known[ssid] = connection_name
    return known


def wifi_device() -> str:
    text = output(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device"])
    fallback = ""
    for line in text.splitlines():
        fields = split_nmcli_line(line)
        if len(fields) < 3 or fields[1] != "wifi":
            continue
        if not fallback:
            fallback = fields[0]
        if fields[2] == "connected":
            return fields[0]
    return fallback


def signal_icon(signal: int) -> str:
    if signal >= 75:
        return "󰤨"
    if signal >= 50:
        return "󰤥"
    if signal >= 25:
        return "󰤢"
    return "󰤟"


def network_state() -> dict[str, Any]:
    wifi_enabled = output(["nmcli", "radio", "wifi"]) == "enabled"
    device = wifi_device()
    known = wifi_connections() if wifi_enabled else {}

    active_ssid = ""
    ip_address = ""
    if device:
        active_lines = output(["nmcli", "-t", "-f", "ACTIVE,SSID", "device", "wifi"])
        for line in active_lines.splitlines():
            fields = split_nmcli_line(line)
            if len(fields) >= 2 and fields[0] == "yes":
                active_ssid = ":".join(fields[1:])
                break
        ip_address = output(["nmcli", "-g", "IP4.ADDRESS", "device", "show", device]).splitlines()[0:1]
        ip_address = ip_address[0].split("/")[0] if ip_address else ""

    networks_by_ssid: dict[str, dict[str, Any]] = {}
    if wifi_enabled:
        text = output(
            [
                "nmcli",
                "-t",
                "--escape",
                "yes",
                "-f",
                "IN-USE,SSID,SIGNAL,SECURITY",
                "device",
                "wifi",
                "list",
                "--rescan",
                "no",
            ],
            timeout=8.0,
        )
        for line in text.splitlines():
            fields = split_nmcli_line(line)
            if len(fields) < 4:
                continue
            in_use, ssid, signal_text = fields[0], fields[1], fields[2]
            security = ":".join(fields[3:])
            if not ssid:
                continue
            try:
                signal = int(signal_text)
            except ValueError:
                signal = 0
            current = networks_by_ssid.get(ssid)
            if current is not None and int(current["signal"]) >= signal:
                continue
            networks_by_ssid[ssid] = {
                "ssid": ssid,
                "token": token(ssid),
                "signal": signal,
                "icon": signal_icon(signal),
                "secure": bool(security and security != "--"),
                "security": "Open" if not security or security == "--" else security,
                "active": in_use == "*" or ssid == active_ssid,
                "known": ssid in known,
            }

    networks = sorted(
        networks_by_ssid.values(),
        key=lambda item: (not bool(item["active"]), -int(item["signal"]), str(item["ssid"]).lower()),
    )

    bluetooth_available = bool(output(["bluetoothctl", "list"]))
    powered_text = output(["bluetoothctl", "show"])
    bluetooth_powered = bool(re.search(r"Powered:\s+yes", powered_text))

    paired_text = output(["bluetoothctl", "devices", "Paired"])
    if not paired_text:
        paired_text = output(["bluetoothctl", "paired-devices"])

    devices: list[dict[str, Any]] = []
    for line in paired_text.splitlines():
        match = re.match(r"Device\s+([0-9A-Fa-f:]{17})\s+(.+)", line)
        if not match:
            continue
        mac, name = match.groups()
        info = output(["bluetoothctl", "info", mac])
        connected = bool(re.search(r"Connected:\s+yes", info))
        battery_match = re.search(r"Battery Percentage:\s+0x[0-9A-Fa-f]+\s+\((\d+)\)", info)
        devices.append(
            {
                "mac": mac,
                "name": name,
                "connected": connected,
                "battery": int(battery_match.group(1)) if battery_match else -1,
            }
        )

    devices.sort(key=lambda item: (not bool(item["connected"]), str(item["name"]).lower()))

    return {
        "wifi_enabled": wifi_enabled,
        "wifi_connected": bool(active_ssid and active_ssid != "--"),
        "ssid": active_ssid if active_ssid and active_ssid != "--" else "Not connected",
        "ip": ip_address or "No IPv4 address",
        "networks": networks[:12],
        "bluetooth_available": bluetooth_available,
        "bluetooth_powered": bluetooth_powered,
        "bluetooth_devices": devices[:10],
    }


def read_number(path: Path) -> int | None:
    try:
        return int(path.read_text().strip())
    except (FileNotFoundError, ValueError, PermissionError):
        return None


def human_time(hours: float | None) -> str:
    if hours is None or hours <= 0 or hours > 48:
        return "Estimating…"
    minutes = round(hours * 60)
    return f"{minutes // 60}h {minutes % 60:02d}m remaining"


def battery_state() -> dict[str, Any]:
    batteries = sorted(Path("/sys/class/power_supply").glob("BAT*"))
    if not batteries:
        return {
            "available": False,
            "capacity": 0,
            "status": "No battery found",
            "time": "",
            "health": 0,
            "power": "",
            "profile": "unavailable",
            "has_power_saver": False,
            "has_balanced": False,
            "has_performance": False,
        }

    battery = batteries[0]
    capacity = read_number(battery / "capacity") or 0
    try:
        status = (battery / "status").read_text().strip()
    except (FileNotFoundError, PermissionError):
        status = "Unknown"

    energy_now = read_number(battery / "energy_now")
    energy_full = read_number(battery / "energy_full")
    energy_design = read_number(battery / "energy_full_design")
    power_now = read_number(battery / "power_now")

    if energy_now is None:
        charge_now = read_number(battery / "charge_now")
        voltage_now = read_number(battery / "voltage_now")
        if charge_now is not None and voltage_now is not None:
            energy_now = charge_now * voltage_now // 1_000_000

    if energy_full is None:
        charge_full = read_number(battery / "charge_full")
        voltage_now = read_number(battery / "voltage_now")
        if charge_full is not None and voltage_now is not None:
            energy_full = charge_full * voltage_now // 1_000_000

    if energy_design is None:
        charge_design = read_number(battery / "charge_full_design")
        voltage_now = read_number(battery / "voltage_now")
        if charge_design is not None and voltage_now is not None:
            energy_design = charge_design * voltage_now // 1_000_000

    if power_now is None:
        current_now = read_number(battery / "current_now")
        voltage_now = read_number(battery / "voltage_now")
        if current_now is not None and voltage_now is not None:
            power_now = current_now * voltage_now // 1_000_000

    hours: float | None = None
    if power_now and energy_now is not None:
        if status == "Charging" and energy_full is not None:
            hours = max(energy_full - energy_now, 0) / power_now
        elif status == "Discharging":
            hours = energy_now / power_now

    health = 0
    if energy_full and energy_design:
        health = round(energy_full / energy_design * 100)

    profile = output(["powerprofilesctl", "get"]) or "unavailable"
    profile_list = output(["powerprofilesctl", "list"])

    return {
        "available": True,
        "capacity": capacity,
        "status": status,
        "time": "Fully charged" if status == "Full" else human_time(hours),
        "health": max(0, min(health, 100)),
        "power": f"{power_now / 1_000_000:.1f} W" if power_now else "Unavailable",
        "profile": profile,
        "has_power_saver": "power-saver:" in profile_list,
        "has_balanced": "balanced:" in profile_list,
        "has_performance": "performance:" in profile_list,
    }


def keyboard_backlight() -> Path | None:
    matches = list(Path("/sys/class/leds").glob("*kbd_backlight*"))
    return matches[0] if matches else None


def display_state() -> dict[str, Any]:
    brightness_text = output(["brightnessctl", "-m"])
    match = re.search(r",(\d+)%,", brightness_text + ",")
    brightness = int(match.group(1)) if match else 0

    keyboard = keyboard_backlight()
    keyboard_available = keyboard is not None
    keyboard_value = 0
    keyboard_max = 0
    if keyboard:
        keyboard_value = read_number(keyboard / "brightness") or 0
        keyboard_max = read_number(keyboard / "max_brightness") or 0

    return {
        "brightness": brightness,
        "night_light": run(["pgrep", "-x", "hyprsunset"]).returncode == 0,
        "keyboard_available": keyboard_available,
        "keyboard_value": keyboard_value,
        "keyboard_max": keyboard_max,
    }


def launch(args: list[str]) -> None:
    try:
        subprocess.Popen(
            args,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except FileNotFoundError:
        pass


def notify(title: str, body: str = "") -> None:
    if command_exists("notify-send"):
        run(["notify-send", title, body])


def set_audio_default(kind: str, encoded_name: str) -> None:
    name = untoken(encoded_name)
    if kind == "sink":
        run(["pactl", "set-default-sink", name])
        for line in output(["pactl", "list", "short", "sink-inputs"]).splitlines():
            stream_id = line.split("\t", 1)[0]
            if stream_id:
                run(["pactl", "move-sink-input", stream_id, name])
    elif kind == "source":
        run(["pactl", "set-default-source", name])
        for line in output(["pactl", "list", "short", "source-outputs"]).splitlines():
            stream_id = line.split("\t", 1)[0]
            if stream_id:
                run(["pactl", "move-source-output", stream_id, name])


def find_known_connection(ssid: str) -> str:
    return wifi_connections().get(ssid, "")


def connect_wifi(encoded_ssid: str) -> None:
    ssid = untoken(encoded_ssid)
    current = network_state()
    if current.get("wifi_connected") and current.get("ssid") == ssid:
        return

    known = find_known_connection(ssid)
    if known:
        result = run(["nmcli", "connection", "up", "id", known], timeout=20.0)
        if result.returncode != 0:
            notify("Wi-Fi connection failed", ssid)
        return

    networks = {item["ssid"]: item for item in current.get("networks", [])}
    network = networks.get(ssid, {})
    if not network.get("secure", True):
        result = run(["nmcli", "device", "wifi", "connect", ssid], timeout=25.0)
        if result.returncode != 0:
            notify("Wi-Fi connection failed", ssid)
        return

    launch(
        [
            "kitty",
            "--hold",
            "--title",
            f"Connect to Wi-Fi · {ssid}",
            "nmcli",
            "--ask",
            "device",
            "wifi",
            "connect",
            ssid,
        ]
    )


def toggle_bluetooth_device(mac: str) -> None:
    info = output(["bluetoothctl", "info", mac])
    action = "disconnect" if re.search(r"Connected:\s+yes", info) else "connect"
    result = run(["bluetoothctl", action, mac], timeout=20.0)
    if result.returncode != 0:
        notify(f"Bluetooth {action} failed", mac)


def toggle_night_light() -> None:
    if run(["pgrep", "-x", "hyprsunset"]).returncode == 0:
        run(["pkill", "-x", "hyprsunset"])
    else:
        launch(["hyprsunset", "-t", "4200"])


def set_keyboard_backlight(value: str) -> None:
    keyboard = keyboard_backlight()
    if keyboard is None:
        return
    run(["brightnessctl", "-d", keyboard.name, "set", value])


def action(args: list[str]) -> None:
    if not args:
        raise SystemExit(2)

    name, *rest = args
    if name == "audio-default" and len(rest) == 2:
        set_audio_default(rest[0], rest[1])
    elif name == "wifi-toggle":
        enabled = output(["nmcli", "radio", "wifi"]) == "enabled"
        run(["nmcli", "radio", "wifi", "off" if enabled else "on"])
    elif name == "wifi-scan":
        run(["nmcli", "device", "wifi", "rescan"], timeout=12.0)
    elif name == "wifi-connect" and len(rest) == 1:
        connect_wifi(rest[0])
    elif name == "wifi-disconnect":
        device = wifi_device()
        if device:
            run(["nmcli", "device", "disconnect", device])
    elif name == "bluetooth-toggle":
        powered = bool(re.search(r"Powered:\s+yes", output(["bluetoothctl", "show"])))
        run(["bluetoothctl", "power", "off" if powered else "on"])
    elif name == "bluetooth-device" and len(rest) == 1:
        toggle_bluetooth_device(rest[0])
    elif name == "bluetooth-scan":
        launch(["bluetoothctl", "--timeout", "12", "scan", "on"])
        notify("Bluetooth scan started", "Nearby devices will appear in Blueman.")
    elif name == "night-light-toggle":
        toggle_night_light()
    elif name == "keyboard-brightness" and len(rest) == 1:
        set_keyboard_backlight(rest[0])
    elif name == "power-profile" and len(rest) == 1:
        run(["powerprofilesctl", "set", rest[0]])
    elif name == "launch-network-editor":
        launch(["nm-connection-editor"])
    elif name == "launch-blueman":
        launch(["blueman-manager"])
    elif name == "launch-pavucontrol":
        launch(["pavucontrol"])
    elif name == "launch-displays":
        launch(["wdisplays"])
    else:
        raise SystemExit(2)


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit("usage: control-center.py <audio|network|battery|display|action>")

    command, *args = sys.argv[1:]
    if command == "audio":
        emit(audio_state())
    elif command == "network":
        emit(network_state())
    elif command == "battery":
        emit(battery_state())
    elif command == "display":
        emit(display_state())
    elif command == "action":
        action(args)
    else:
        raise SystemExit(2)


if __name__ == "__main__":
    main()
