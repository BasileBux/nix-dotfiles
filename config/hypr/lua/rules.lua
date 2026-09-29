local f_str = function(s, tab)
	return (s:gsub("($%b{})", function(w)
		return tab[w:sub(3, -2)] or w
	end))
end

hl.window_rule({
	name = "pip-float",
	match = { title = "Picture.in.[Pp]icture" }, -- regex: matches "Picture-in-Picture" (chrome/firefox) and "Picture in picture" (helium)
	float = true,
	no_dim = true,
	no_anim = true,
})

hl.window_rule({
	name = "quickshell-float",
	match = { class = "org.quickshell", title = "Authentication Required" },
	float = true,
})

hl.window_rule({
	name = "remote-ssh",
	match = { class = "org.quickshell", title = "Remote ssh" },
	float = true,
	center = true,
})

hl.window_rule({
	name = "tailscale-panel",
	match = { class = "org.quickshell", title = "Tailscale" },
	float = true,
})

hl.window_rule({
	name = "emulator-float",
	match = { class = "Emulator" },
	float = true,
})

local settings = require("lua.settings")
for _, fe in pairs(settings.file_explorers) do
	hl.window_rule({
		name = fe.class .. "-float",
		match = { class = fe.class },
		float = true,
	})
end

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

local popup_width = 0.8
local popup_height = 0.8
local popups = { "scratch", "todo", "quick-ai" }

for _, popup in ipairs(popups) do
	hl.window_rule({
		name = popup,
		match = { title = popup },
		float = true,
		size = f_str("(monitor_w*${width}) (monitor_h*${height})", { width = popup_width, height = popup_height }),
		move = f_str(
			"(monitor_w*${x_off}) (monitor_h*${y_off})",
			{ x_off = center(popup_width), y_off = center(popup_height) }
		),
	})
end

-- ----------------
-- WORKSPACE RULES
-- ----------------

local editor = "nvim"

hl.workspace_rule({
	workspace = "special:sagepopup",
	on_created_empty = "kitty --title='sagepopup' -e nu -c 'sage -q'",
})

hl.workspace_rule({
	workspace = "special:scratch",
	on_created_empty = "kitty --title='scratch' -e nu -c '" .. editor .. " ~/scratch.md'",
})

hl.workspace_rule({
	workspace = "special:todo",
	on_created_empty = "kitty --title='todo' -e nu -c '" .. editor .. " +Todo'",
})

hl.workspace_rule({
	workspace = "special:quick-ai",
	on_created_empty = "kitty --title='quick-ai' -d ~/tmp/quick-ai -e nu -c 'VISUAL=" .. editor .. " pi'",
})
