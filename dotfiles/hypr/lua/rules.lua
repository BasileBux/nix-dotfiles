hl.window_rule({
	name = "pip-float",
	match = { title = "Picture-in-Picture" },
	float = true,
})

hl.window_rule({
	name = "quickshell-float",
	match = { title = "quickshell" },
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

hl.window_rule({
	name = "sagepopup",
	match = { title = "sagepopup" },
	float = true,
	size = "(monitor_w*0.6) (monitor_h*0.3)",
	move = "(monitor_w*0.2) (monitor_h*0.02)",
})

hl.window_rule({
	name = "scratch",
	match = { title = "scratch" },
	float = true,
	size = "(monitor_w*0.8) (monitor_h*0.8)",
	move = "(monitor_w*0.1) (monitor_h*0.1)",
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
