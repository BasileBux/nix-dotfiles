hl.config({
	dwindle = {
		preserve_split = true,
	},

	misc = {
		disable_hyprland_logo = true,
		force_default_wallpaper = -1,
	},

	binds = {
		allow_workspace_cycles = true,
	},

	cursor = {
		enable_hyprcursor = true,
	},

	xwayland = {
		force_zero_scaling = true,
	},

	general = {
		allow_tearing = false,
		border_size = 2,
		col = {
			active_border = "0xFF676767",
			inactive_border = "0x00000000",
		},
		gaps_in = 1,
		gaps_out = 3,
		layout = "dwindle",
	},
	decoration = {
		blur = {
			enabled = true,
			passes = 1,
			size = 4,
		},
		shadow = {
			enabled = false,
		},
		dim_inactive = true,
		dim_strength = 0.2,
		rounding = 7,
	},
	animations = {
		enabled = true,
	},
})

hl.curve("pop", { type = "bezier", points = { { 0.39, 0.575 }, { 0.565, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.5, 0.5 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "pop", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "linear", style = "popin 70%" })
hl.animation({ leaf = "fade", enabled = false })
hl.animation({ leaf = "workspaces", enabled = true, speed = 0.6, bezier = "linear", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 0.8, bezier = "linear", style = "slidevert top" })
hl.animation({
	leaf = "specialWorkspaceOut",
	enabled = true,
	speed = 0.8,
	bezier = "linear",
	style = "slidevert bottom",
})
