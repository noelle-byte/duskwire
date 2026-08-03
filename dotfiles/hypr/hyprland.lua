-- ============================================================
-- DUSKWIRE // HYPRLAND
-- ============================================================

require("modules.monitors")
require("modules.input")

require("modules.appearance")
require("modules.animations")

require("modules.layouts")
require("modules.rules")

require("modules.autostart")
require("modules.keybinds")


---------------------
---- ENVIRONMENT ----
---------------------

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/


---------------------
---- PERMISSIONS ----
---------------------

-- Permission changes require a complete Hyprland restart.
--
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/

-- hl.config({
--     ecosystem = {
--         enforce_permissions = true,
--     },
-- })

-- hl.permission(
--     "/usr/(bin|local/bin)/grim",
--     "screencopy",
--     "allow"
-- )

-- hl.permission(
--     "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland",
--     "screencopy",
--     "allow"
-- )

-- hl.permission(
--     "/usr/(bin|local/bin)/hyprpm",
--     "plugin",
--     "allow"
-- )





-- ------------------------------------------------------------
-- Audio
-- ------------------------------------------------------------

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
    ),
    {
        locked    = true,
        repeating = true,
    }
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ),
    {
        locked    = true,
        repeating = true,
    }
)

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ),
    {
        locked    = true,
        repeating = true,
    }
)

hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ),
    {
        locked    = true,
        repeating = true,
    }
)


-- ------------------------------------------------------------
-- Brightness
-- ------------------------------------------------------------

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd(
        "brightnessctl -e4 -n2 set 5%+"
    ),
    {
        locked    = true,
        repeating = true,
    }
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd(
        "brightnessctl -e4 -n2 set 5%-"
    ),
    {
        locked    = true,
        repeating = true,
    }
)


-- ------------------------------------------------------------
-- Media
-- ------------------------------------------------------------

hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"),
    {
        locked = true,
    }
)

hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    {
        locked = true,
    }
)

hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"),
    {
        locked = true,
    }
)

hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    {
        locked = true,
    }
)


----------------------
