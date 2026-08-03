#!/usr/bin/env fish

# ============================================================
# DUSKWIRE // WAYBAR CONNECTIVITY
# ============================================================


# ------------------------------------------------------------
# Wi-Fi
# ------------------------------------------------------------

set wifi_state (nmcli radio wifi 2>/dev/null)

set ssid (
    nmcli -t -f ACTIVE,SSID device wifi 2>/dev/null \
    | string match "yes:*" \
    | string replace "yes:" "" \
    | head -n 1
)

if test "$wifi_state" = "enabled"
    if test -n "$ssid"
        set wifi_icon "󰤨"
        set wifi_text "$ssid"
        set connection_class "connected"
    else
        set wifi_icon "󰤯"
        set wifi_text "Not connected"
        set connection_class "idle"
    end
else
    set wifi_icon "󰤭"
    set wifi_text "Disabled"
    set connection_class "offline"
end


# ------------------------------------------------------------
# Bluetooth
# ------------------------------------------------------------

set bluetooth_powered (
    bluetoothctl show 2>/dev/null \
    | string match -r '^\s*Powered: yes'
)

set bluetooth_device (
    bluetoothctl devices Connected 2>/dev/null \
    | string replace -r '^Device [^ ]+ ' '' \
    | head -n 1
)

if test -n "$bluetooth_powered"
    if test -n "$bluetooth_device"
        set bluetooth_icon "󰂱"
        set bluetooth_text "$bluetooth_device"
    else
        set bluetooth_icon "󰂯"
        set bluetooth_text "On"
    end
else
    set bluetooth_icon "󰂲"
    set bluetooth_text "Off"
end


# ------------------------------------------------------------
# Waybar output
# ------------------------------------------------------------

set module_text "$wifi_icon  $bluetooth_icon"
set tooltip "Wi-Fi: $wifi_text  •  Bluetooth: $bluetooth_text"

# ------------------------------------------------------------
# JSON output
# ------------------------------------------------------------

function json_escape
    string replace -a '\\' '\\\\' -- $argv[1] \
        | string replace -a '"' '\"'
end

set module_text (json_escape "$module_text")
set tooltip (json_escape "$tooltip")

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$module_text" "$tooltip" "$connection_class"
