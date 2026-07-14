local config = require("config")

local monitors_setup = function()
	local primary_mon = config.monitors.primary
	local secondary_mon = config.monitors.secondary
	hl.monitor({
		output = "desc:" .. primary_mon.description,
		mode = primary_mon.mode,
		position = primary_mon.position,
		scale = primary_mon.scale,
	})

	hl.monitor({
		output = "desc:" .. secondary_mon.description,
		mode = secondary_mon.mode,
		position = secondary_mon.position,
		scale = secondary_mon.scale,
	})

	local mons = hl.get_monitors()
	local found_secondary = false
	for _, mon in pairs(mons) do
		if mon.description == secondary_mon.description then
			found_secondary = true
			hl.monitor({
				output = "desc:" .. primary_mon.description,
				disabled = true,
			})
		end
	end

	-- Mirror all monitors which aren't the secondary one
	if not found_secondary and #mons > 1 then
		hl.monitor({
			output = "desc:" .. primary_mon.description,
			mode = primary_mon.mirror.mode, -- To have 16:9 aspect ratio for mirroring
			scale = primary_mon.mirror.scale,
			disabled = false,
		})
		hl.monitor({
			output = "",
			mode = "preferred",
			position = "auto",
			scale = "auto",
			mirror = "desc:" .. primary_mon.description,
		})
	end
	hl.exec_cmd("pkill quickshell; quickshell")
end

monitors_setup()

hl.on("monitor.removed", function()
	local mons = hl.get_monitors()
	if #mons == 1 then
		-- We cannot simply run `monitors_setup()` because for some reason it won't
		-- re-enable the primary monitor if it's disabled
		hl.exec_cmd("hyprctl reload")
	end
end)

hl.on("monitor.added", function()
	monitors_setup()
end)
