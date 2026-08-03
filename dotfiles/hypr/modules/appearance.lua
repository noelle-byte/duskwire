local theme = require("lib.theme")


-- Visual tuning

local appearance = {
    gaps = {
        inner = 6,
        outer = 10,
    },

    border = {
        size  = 3,
        angle = 45,
    },

    rounding = {
        radius = 10,
        power  = 2.0,
    },

    opacity = {
        active     = 1.0,
        inactive   = 0.8,
        fullscreen = 1.0,
    },

    dimming = {
        enabled  = true,
        strength = 0.10,
    },

    shadow = {
        enabled     = false,
        range       = 20,
        renderPower = 3,
    },

    blur = {
        enabled          = true,
        size             = 8,
        passes           = 3,
        contrast         = 1.05,
        brightness       = 0.86,
        vibrancy         = 0.22,
        vibrancyDarkness = 0.10,
    },
}


-- Apply appearence

hl.config({
    general = {
        gaps_in  = appearance.gaps.inner,
        gaps_out = appearance.gaps.outer,

        border_size = appearance.border.size,

        col = {
            active_border = {
                colors = {
                    theme.rgba("lavender"),
                    theme.rgba("orchid"),
                    theme.rgba("pink"),
                    theme.rgba("amber"),
                },

                angle = appearance.border.angle,
            },

            inactive_border = theme.rgba("indigo"),
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = appearance.rounding.radius,
        rounding_power = appearance.rounding.power,

        active_opacity     = appearance.opacity.active,
        inactive_opacity   = appearance.opacity.inactive,
        fullscreen_opacity = appearance.opacity.fullscreen,

        dim_inactive = appearance.dimming.enabled,
        dim_strength = appearance.dimming.strength,

        shadow = {
            enabled      = appearance.shadow.enabled,
            range        = appearance.shadow.range,
            render_power = appearance.shadow.renderPower,
            color        = theme.argb("shadow"),
        },

        blur = {
            enabled           = appearance.blur.enabled,
            size              = appearance.blur.size,
            passes            = appearance.blur.passes,
            contrast          = appearance.blur.contrast,
            brightness        = appearance.blur.brightness,
            vibrancy          = appearance.blur.vibrancy,
            vibrancy_darkness = appearance.blur.vibrancyDarkness,
            popups            = true,
        },
    },

    animations = {
        enabled = true,
    },
})


--  Misc

hl.config({
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,

        animate_manual_resizes       = true,
        animate_mouse_windowdragging = true,
    },
})


hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
