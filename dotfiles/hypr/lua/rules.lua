local f_str = function(s, tab)
	return (s:gsub("($%b{})", function(w)
		return tab[w:sub(3, -2)] or w
	end))
end

hl.window_rule({
	name = "pip-float",
	match = { title = "Picture-in-Picture" },
	float = true,
})

hl.window_rule({
	name = "quickshell-float",
	match = { class = "org.quickshell", title = "Authentication Required" },
	float = true,
})

hl.window_rule({
	name = "emulator-float",
	match = { class = "Emulator" },
	float = true,
})

hl.window_rule({
	name = "nautilus-float",
	match = { class = "org.gnome.Nautilus" },
	float = true,
})

hl.window_rule({
	name = "calculator-float",
	match = { class = "org.gnome.Calculator" },
	float = true,
})

local center = function(width)
	return (1 - width) / 2
end

local sagepopup_width = 0.6
hl.window_rule({
	name = "sagepopup",
	match = { title = "sagepopup" },
	float = true,
	size = f_str("(monitor_w*${width}) (monitor_h*${height})", { width = sagepopup_width, height = 0.3 }),
	move = f_str("(monitor_w*${x_off}) (monitor_h*${y_off})", { x_off = center(sagepopup_width), y_off = 0.02 }),
})

local scratch_width = 0.8
local scratch_height = 0.8
hl.window_rule({
	name = "scratch",
	match = { title = "scratch" },
	float = true,
	size = f_str("(monitor_w*${width}) (monitor_h*${height})", { width = scratch_width, height = scratch_height }),
	move = f_str(
		"(monitor_w*${x_off}) (monitor_h*${y_off})",
		{ x_off = center(scratch_width), y_off = center(scratch_height) }
	),
})

-- ----------------
-- WORKSPACE RULES
-- ----------------

hl.workspace_rule({
	workspace = "special:sagepopup",
	on_created_empty = "kitty --title='sagepopup' -e sh -c 'sage || python3'",
})

hl.workspace_rule({
	workspace = "special:scratch",
	on_created_empty = "kitty --title='scratch' -e sh -c 'nvim ~/tmp/notes/daily-$(date +%d-%b-%Y).md'",
})
