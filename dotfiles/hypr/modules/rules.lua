-- WORKSPACE RULES

-- Optional smart gaps:
--
-- hl.workspace_rule({
--     workspace = "w[tv1]",
--     gaps_out  = 0,
--     gaps_in   = 0,
-- })
--
-- hl.workspace_rule({
--     workspace = "f[1]",
--     gaps_out  = 0,
--     gaps_in   = 0,
-- })
--
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = {
--         float     = false,
--         workspace = "w[tv1]",
--     },
--
--     border_size = 0,
--     rounding    = 0,
-- })
--
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = {
--         float     = false,
--         workspace = "f[1]",
--     },
--
--     border_size = 0,
--     rounding    = 0,
-- })


-- Window rules guide

-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/


-- Ignore application maximise requests

local suppressMaximizeRule = hl.window_rule({
    name = "suppress-maximize-events",

    match = {
        class = ".*",
    },

    suppress_event = "maximize",
})

-- suppressMaximizeRule:set_enabled(false)


-- XWayland dragging workaround

hl.window_rule({
    name = "fix-xwayland-drags",

    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})


-- Hyprland Run

hl.window_rule({
    name = "move-hyprland-run",

    match = {
        class = "hyprland-run",
    },

    move  = "20 monitor_h-120",
    float = true,
})
