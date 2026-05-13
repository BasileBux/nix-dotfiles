local M = {}

M.swap_lalt_lwin = function()
	local base = hl.get_config("input.kb_options")
	local suffix = ",altwin:swap_lalt_lwin"
	local new_options = string.find(base, suffix, 1, true) and string.gsub(base, suffix, "") or base .. suffix
	hl.config({ input = { kb_options = new_options } })
end

M.setup = function()
	hl.config({
		input = {
			touchpad = {
				natural_scroll = true,
			},
			follow_mouse = 1,
			kb_layout = "us,ch",
			kb_options = "grp:alt_space_toggle,ctrl:nocaps",
			kb_variant = ",fr",
			repeat_delay = 250,
			repeat_rate = 35,
			sensitivity = 0,
		},
	})

	hl.device({
		name = "logitech-pro-x-1",
		accel_profile = "flat",
		sensitivity = -0.2,
	})

	hl.device({
		name = "logitech-pro-x-wireless-1",
		accel_profile = "flat",
		sensitivity = -0.2,
	})

	hl.device({
		name = "logitech-pro-x-wireless-2",
		accel_profile = "flat",
		sensitivity = -0.2,
	})

	hl.gesture({
		fingers = 3,
		direction = "horizontal",
		action = "workspace",
	})
end

return M
