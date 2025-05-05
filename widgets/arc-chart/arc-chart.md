# This is simply an arc chart widget where you can have multiple arc charts

* Below is the configuration shows how it can be used

```lua

        local arc_config = {
            { 
		name = "arc1", 
		cmd_int = "free -h -w | grep Mem | awk '{print $3}' | tr -d 'Gi'", 
		style = { 
			margin = 0, 
			color = "#a80031", 
			thickness = 25, 
			min = 1, 
			max = 100, 
			border_width = 0, 
			border_color = "#ffffff", 
			visibility = true, 
			rounded = true 
		}, 
		icon_type = "", 
		img_path = "", 
		icon = " ", 
		icon_color="#ffffff" 
	},
            -- { name = "arc2", cmd_int = "date +%S", style = { margin = 30, color = "#ffff0066", thickness = 25, min = 1, max = 100, border_width = 0, border_color = "#ffff00", visibility = true, rounded = false }, icon_type = "img/icon", img_path = ".config/awesome/icons/notebook.svg.config/awesome/icons/notebook.svg", icon = "󰻠" },
            -- { name = "arc3", cmd_int = "date +%S", style = { margin = 60, color = "#ffff0055", thickness = 25, min = 1, max = 100, border_width = 0, border_color = "#f00f00", visibility = true, rounded = false }, icon_type = "img/icon", img_path = ".config/awesome/icons/notebook.svg", icon = "󰻠" },
            -- { name = "arc4", cmd_int = "date +%S", style = { margin = 90, color = "#ffff0044", thickness = 25, min = 1, max = 100, border_width = 0, border_color = "#ffff00", visibility = true, rounded = false }, icon_type = "img/icon", img_path = ".config/awesome/icons/notebook.svg", icon = "󰻠" },
            -- { name = "arc5", cmd_int = "date +%S", style = { margin = 120, color = "#fff00033", thickness = 25, min = 1, max = 100, border_width = 0, border_color = "#ffff00", visibility = true, rounded = false }, icon_type = "img/icon", img_path = ".config/awesome/icons/notebook.svg", icon = "󰻠" },
            -- { name = "arc6", cmd_int = "date +%S", style = { margin = 150, color = "#ffff0022", thickness = 25, min = 1, max = 100, border_width = 0, border_color = "#ffff00", visibility = true, rounded = false }, icon_type = "img/icon", img_path = ".config/awesome/icons/notebook.svg", icon = "󰻠" },
        }

  

        require("extra_widgets.cool_widz").draw_cool_widz(s, 300, 40, 24, 50, arc_config)


```
