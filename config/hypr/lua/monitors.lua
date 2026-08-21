local config = require("config")

-- Description of the monitor layout we last converged to. Used to only
-- restart quickshell when the effective layout actually changes, instead of
-- on every monitor event.
local last_key = nil

-- Timestamp (os.time) of the last recovery reload issued by the
-- `monitor.removed` handler below, used to keep reload cascades from chaining.
local last_recovery_reload = 0

local classify = function(mons)
	local builtin = nil
	local known = {}
	local unknowns = {}

	for _, entry in ipairs(config.monitors) do
		for _, mon in pairs(mons) do
			if mon.description == entry.description then
				if entry.builtin then
					builtin = { entry = entry }
				else
					table.insert(known, { entry = entry })
				end
			end
		end
	end

	local known_descs = {}
	for _, entry in ipairs(config.monitors) do
		known_descs[entry.description] = true
	end
	for _, mon in pairs(mons) do
		if not known_descs[mon.description] then
			table.insert(unknowns, mon)
		end
	end

	return builtin, known, unknowns
end

local enable = function(entry)
	hl.monitor({
		output = "desc:" .. entry.description,
		mode = entry.mode,
		position = "0x0",
		scale = entry.scale,
	})
end

local disable_all_except = function(description)
	for _, mon in pairs(hl.get_monitors()) do
		if mon.description ~= description then
			hl.monitor({
				output = "desc:" .. mon.description,
				disabled = true,
			})
		end
	end
end

local finish = function(key)
	-- Ignore transient empty states (mid-reload, mid output re-init): there is
	-- nothing to show a shell on, and restarting quickshell for them would only
	-- burn through systemd's start limit. Keep `last_key` untouched so the real
	-- layout that follows still counts as a change.
	if key == "none" or key == last_key then
		return
	end
	last_key = key
	hl.exec_cmd("systemctl --user restart quickshell.service")
end

local monitors_setup = function()
	local mons = hl.get_monitors()
	local builtin, known, unknowns = classify(mons)

	if #known > 0 then
		-- A known external is always the most important monitor: enable the first
		-- one in priority order and disable everything else (builtin included).
		local driver = known[1].entry
		enable(driver)
		disable_all_except(driver.description)
		finish("known:" .. driver.description)
	elseif builtin ~= nil then
		local b = builtin.entry
		if #unknowns > 0 and b.mirror ~= nil then
			-- Unknown outputs (projectors, TVs, ...): drive from the builtin panel
			-- forced to its 16:9 mirror mode, and mirror every unknown onto it.
			enable({ description = b.description, mode = b.mirror.mode, scale = b.mirror.scale })
			hl.monitor({
				output = "", -- generic rule: applies to all monitors without a specific one
				mode = "preferred",
				position = "auto",
				scale = "auto",
				mirror = "desc:" .. b.description,
			})
			finish("mirror:" .. b.description .. ":" .. #unknowns)
		else
			-- Builtin alone (or unknowns but no mirror config): native mode.
			enable(b)
			for _, mon in pairs(unknowns) do
				hl.monitor({
					output = "desc:" .. mon.description,
					disabled = true,
				})
			end
			finish("builtin:" .. b.description)
		end
	elseif #unknowns > 0 then
		-- No builtin (tower or laptop with panel gone): enable the first unknown
		-- at its preferred mode, disable any other unknowns. One at a time.
		hl.monitor({
			output = "desc:" .. unknowns[1].description,
			mode = "preferred",
			position = "0x0",
			scale = "auto",
		})
		for i, mon in pairs(unknowns) do
			if i > 1 then
				hl.monitor({
					output = "desc:" .. mon.description,
					disabled = true,
				})
			end
		end
		finish("unknown:" .. unknowns[1].description)
	else
		finish("none")
	end
end

monitors_setup()

hl.on("monitor.removed", function()
	-- Only recover when no enabled monitor is left (e.g. the driver was
	-- unplugged while the builtin panel is disabled). Reacting to removals we
	-- caused ourselves (disabling the builtin because a known external is
	-- plugged in) would re-enable it and feed an infinite
	-- disable -> removed -> reload -> re-enable -> added loop.
	if #hl.get_monitors() == 0 then
		-- We cannot simply run `monitors_setup()` because a disabled monitor no
		-- longer shows up in `get_monitors()`, so there is nothing left to match
		-- against. A reload makes Hyprland re-apply the config and bring the
		-- remaining panel back.
		--
		-- Cooldown: re-enabling an output can make it re-init, which briefly
		-- fires another removal with an empty list. Without this guard each such
		-- removal would trigger yet another full reload (and reset this script's
		-- state), chaining into a burst of restarts.
		local now = os.time()
		if now - last_recovery_reload >= 2 then
			last_recovery_reload = now
			hl.exec_cmd("hyprctl reload")
		end
	end
end)

hl.on("monitor.added", function()
	monitors_setup()
end)
