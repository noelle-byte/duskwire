local theme = {}

local configHome = os.getenv("XDG_CONFIG_HOME")
    or (os.getenv("HOME") .. "/.config")

local palettePath = configHome .. "/duskwire/colors.conf"
local raw = {}

for line in io.lines(palettePath) do
    local key, value =
        line:match("^([%a][%w_-]*)=([%x]+)$")

    if key ~= nil then
        if #value ~= 8 then
            error(
                "Theme colour '" .. key
                .. "' must use RRGGBBAA format"
            )
        end

        raw[key] = value:lower()
    end
end

local function get(name)
    local value = raw[name]

    if value == nil then
        error("Missing theme colour: " .. name)
    end

    return value
end

-- Hyprland string format:
-- rgba(RRGGBBAA)
function theme.rgba(name)
    return "rgba(" .. get(name) .. ")"
end

-- Hyprland numeric format:
-- 0xAARRGGBB
function theme.argb(name)
    local value = get(name)

    local rgb = value:sub(1, 6)
    local alpha = value:sub(7, 8)

    return tonumber(alpha .. rgb, 16)
end

function theme.hex(name)
    return "#" .. get(name):sub(1, 6)
end

theme.raw = raw

return theme
