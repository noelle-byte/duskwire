#!/usr/bin/env fish

set -l target $argv[1]

set -l popup_windows \
    audio-popup \
    brightness-popup \
    battery-popup \
    network-popup

if not contains -- "$target" $popup_windows
    echo "Unknown popup: $target" >&2
    exit 1
end

# Start the Eww daemon when it is not already running.
if not pgrep -x eww >/dev/null
    eww daemon >/tmp/eww-daemon.log 2>&1
    sleep 0.25
end

set -l active_windows (eww active-windows 2>/dev/null)
set -l was_open false

if string match -q "*$target*" -- $active_windows
    set was_open true
end

# Only keep one control popup open at a time.
for window in $popup_windows
    eww close "$window" >/dev/null 2>&1
end

if test "$was_open" = false
    eww open "$target" >/tmp/eww-popup.log 2>&1
end