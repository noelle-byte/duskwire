-- Shortcuts

local mainMod = "SUPER"

local screenshot = "duskwire-screenshot"

local apps = {
    terminal    = "kitty",
    browser     = "firefox",
    fileManager = "thunar",
    launcher    = "wofi --show drun",
}


-- Binds

hl.bind(
    mainMod .. " + return",
    hl.dsp.exec_cmd(apps.terminal)
)

hl.bind(
    mainMod .. " + F",
    hl.dsp.exec_cmd(apps.fileManager)
)

hl.bind(
    mainMod .. " + D",
    hl.dsp.exec_cmd(apps.launcher)
)

hl.bind(
    mainMod .. " + B",
    hl.dsp.exec_cmd(apps.browser)
)


-- Session management

hl.bind(
    mainMod .. " + M",
    hl.dsp.exec_cmd(
        "command -v hyprshutdown >/dev/null 2>&1"
        .. " && hyprshutdown"
        .. " || hyprctl dispatch 'hl.dsp.exit()'"
    )
)


-- Window management

local closeWindowBind = hl.bind(
    mainMod .. " + X",
    hl.dsp.window.close()
)

-- closeWindowBind:set_enabled(false)

hl.bind(
    mainMod .. " + V",
    hl.dsp.window.float({
        action = "toggle",
    })
)

hl.bind(
    mainMod .. " + P",
    hl.dsp.window.pseudo()
)

hl.bind(
    mainMod .. " + I",
    hl.dsp.layout("togglesplit")
)


-- Focus movement

hl.bind(
    mainMod .. " + H",
    hl.dsp.focus({
        direction = "left",
    })
)

hl.bind(
    mainMod .. " + L",
    hl.dsp.focus({
        direction = "right",
    })
)

hl.bind(
    mainMod .. " + J",
    hl.dsp.focus({
        direction = "up",
    })
)

hl.bind(
    mainMod .. " + K",
    hl.dsp.focus({
        direction = "down",
    })
)

-- Move active window

hl.bind(
    mainMod .. " + SHIFT + H",
    hl.dsp.window.move({
        direction = "left",
    }),
    {
        repeating = true,
    }
)

hl.bind(
    mainMod .. " + SHIFT + L",
    hl.dsp.window.move({
        direction = "right",
    }),
    {
        repeating = true,
    }
)

hl.bind(
    mainMod .. " + SHIFT + J",
    hl.dsp.window.move({
        direction = "up",
    }),
    {
        repeating = true,
    }
)

hl.bind(
    mainMod .. " + SHIFT + K",
    hl.dsp.window.move({
        direction = "down",
    }),
    {
        repeating = true,
    }
)

-- Workspaces

for workspace = 1, 10 do
    local key = workspace % 10

    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({
            workspace = workspace,
        })
    )

    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({
            workspace = workspace,
        })
    )
end


-- Special workspace / scratchpad

hl.bind(
    mainMod .. " + S",
    hl.dsp.workspace.toggle_special("magic")
)

hl.bind(
    mainMod .. " + SHIFT + S",
    hl.dsp.window.move({
        workspace = "special:magic",
    })
)


-- Workspace scrolling

hl.bind(
    mainMod .. " + mouse_down",
    hl.dsp.focus({
        workspace = "e+1",
    })
)

hl.bind(
    mainMod .. " + mouse_up",
    hl.dsp.focus({
        workspace = "e-1",
    })
)


-- Mouse window controls

hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    {
        mouse = true,
    }
)

hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    {
        mouse = true,
    }
)

-- Screenshots

-- Select an area, save it and copy it.
hl.bind(
    "Print",
    hl.dsp.exec_cmd(screenshot .. " area")
)

-- Capture the full desktop, save it and copy it.
hl.bind(
    "SHIFT + Print",
    hl.dsp.exec_cmd(screenshot .. " full")
)
