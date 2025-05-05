local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local rubato = require("lib.rubato")
local config = require("confs.config").vars
local home_dir = os.getenv("HOME")

local function get_arc(
    name,
    initial_value,
    margin,
    color,
    thickness,
    min,
    max,
    border_width,
    border_color,
    visible,
    rounded,
    icon_type,
    img_path,
    icon,
    icon_color)
    local arc_chart = wibox.widget {
        id = name,
        max_value = max,
        min_value = min,
        value = initial_value,
        start_angle = math.pi,
        rounded_edge = rounded,
        visibility = visible,
        border_color = border_color,
        border_width = border_width,
        thickness = thickness,
        bg = "#00000000",
        colors = { color },
        widget = wibox.container.arcchart
    }
    -- local arc_icon = gears.color.recolor_image(home_dir .. "/.config/awesome/icons/notebook.svg",
    --     config.icons_df_clr_on_hover)

    local arc_value = wibox.widget {
        widget = wibox.widget.textbox,
        markup = "<span font='JetBrainsMono 10' >" .. tostring(initial_value) .. "</span>",
        align = "center"
    }

    local arc_icon = function(type, path, ic)
        if type == "img" then
            if path ~= "" then
                return wibox.widget {
                    widget = wibox.widget.imagebox,
                    image = gears.color.recolor_image(home_dir .. "/" .. tostring(path), config.icons_df_clr_on_hover)
                }
            else
                return wibox.widget {
                    widget = wibox.widget.textbox,
                    text = ""
                }
            end
        else
            return wibox.widget {
                {
                    {
                        {
                            markup = "<span color='" .. icon_color .. "' font='JetBrainsMono 10'>" .. "<b>" .. tostring(ic) .. "</b>" .. "</span>",
                            widget = wibox.widget.textbox,
                            align  = "center",
                            valign = "center"
                        },
                        widget = wibox.container.place,
                        halign = "center",
                        valign = "center"
                    },
                    widget = wibox.container.margin,
                    margins = { top = 0, bottom = 0, left = 4, right = 0 }
                },
                widget = wibox.container.background,
                bg = tostring(color) .. "77",
                shape = function(cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, 8)
                end
            }
        end
    end
    local arc_box = wibox.widget {
        {
            arc_chart,
            {
                {
                    {
                        {
                            {
                                arc_icon(icon_type, img_path, icon),
                                widget = wibox.container.mirror,
                                reflection = {
                                    horizontal = true,
                                    vertical = false,
                                }
                            },
                            nil,
                            {
                                arc_value,
                                widget = wibox.container.mirror,
                                reflection = {
                                    horizontal = true,
                                    vertical = false,
                                }
                            },
                            layout = wibox.layout.flex.vertical
                        },
                        widget = wibox.widget.background,
                        -- bg = "#00ffff",
                        forced_width = 25,
                        forced_height = 60
                    },
                    widget = wibox.container.place,
                    halign = "right"
                },
                widget = wibox.container.margin,
                margins = { top = 76, bottom = 0, left = 0, right = 0 }
            },
            layout = wibox.layout.stack
        },
        widget = wibox.container.margin,
        margins = margin
    }

    return arc_box, arc_chart, arc_value
end

local function setup_arc_animation(chart)
    return rubato.timed {
        duration = 0.6,
        easing = rubato.easing.linear,
        subscribed = function(pos)
            chart.value = pos
        end
    }
end

local function create_arcs(config)
    local arc_boxes = {}
    local arc_state = {}

    for _, arc in pairs(config) do
        local arc_box, chart, arc_value = get_arc(
            arc.name,
            0,
            arc.style.margin,
            arc.style.color,
            arc.style.thickness,
            arc.style.min,
            arc.style.max,
            arc.style.border_width,
            arc.style.border_color,
            arc.style.visible,
            arc.style.rounded,
            arc.icon_type,
            arc.img_path,
            arc.icon,
            arc.icon_color
        )
        local animator = setup_arc_animation(chart)

        arc_state[arc.name] = {
            container = arc_box,
            chart = chart,
            animate = animator,
            update = function(val)
                animator.target = val
                arc_value.markup = "<span font='JetBrainsMono 10'>"..tostring(math.floor(val)).."</span>"
            end,
            cmd = arc.cmd_int
        }

        table.insert(arc_boxes, arc_box)
    end

    return arc_boxes, arc_state
end

-- Periodically update arcs with command output
local function start_arc_updater(state_table)
    gears.timer {
        timeout = 1,
        autostart = true,
        call_now = true,
        callback = function()
            for name, arc in pairs(state_table) do
                awful.spawn.easy_async_with_shell(arc.cmd, function(stdout, stderr, reason, exit_code)
                    local val = tonumber(stdout)
                    if val == nil then
                        naughty.notification({
                            text = 'value : ' .. tostring(val) ..
                                '\nstderr : ' .. tostring(stderr) ..
                                '\nreason' .. tostring(reason) ..
                                '\nexit_code' .. tostring(exit_code)
                        })
                    end
                    if val then
                        arc.update(val)
                    end
                end)
            end
        end
    }
end

-- Main popup draw function
local function draw_cool_widz(screen, x, y, w_percent, h_percent, config)
    if not config then
        naughty.notification({ title = "Missing Config", text = "Please provide configuration." })
        error("Missing configuration")
    end

    local screen_geom = screen.geometry
    local width = w_percent * screen_geom.width / 100
    local height = h_percent * screen_geom.height / 100

    local arc_boxes, arc_state = create_arcs(config)

    local widget_stack = wibox.widget {
        {
            layout = wibox.layout.stack,
            table.unpack(arc_boxes)
        },
        reflection = {
            vertical = false,
            horizontal = true
        },
        widget = wibox.container.mirror
    }

    awesome.register_xproperty("WM_NAME", "string")
    awesome.register_xproperty("WM_CLASS", "string")
    local popup = awful.popup {
        widget = {
            widget_stack,
            widget = wibox.widget.background,
            forced_width = width,
            forced_height = height,
        },
        screen = screen,
        x = x,
        y = y,
        bg = "#00000000",
        ontop = false,
        visible = true
    }

    start_arc_updater(arc_state)
    popup:set_xproperty("WM_CLASS", "Arcz")
    popup:set_xproperty("WM_NAME", "Arcz")

    return popup, arc_state
end

return {
    draw_cool_widz = draw_cool_widz
}

