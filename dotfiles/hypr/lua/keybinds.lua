local terminal = "kitty"
local input = require("lua.input")
local config = require("config")
local settings = require("lua.settings")

local mainMod = config.mainMod
local file_explorer = settings.file_explorer

local toggle_file_explorer = function()
	local wins = hl.get_windows({ class = file_explorer.class })
	local active = hl.get_active_window()

	if #wins == 0 then
		hl.exec_cmd(file_explorer.cmd)
		return
	end

	local win = wins[1]

	if active ~= nil and active.address == win.address then
		hl.dispatch(hl.dsp.window.move({
			window = win,
			workspace = "special:shadowrealm",
			follow = false,
		}))
		return
	end

	local ws = hl.get_active_workspace()

	if ws ~= nil then
		hl.dispatch(hl.dsp.window.move({
			window = win,
			workspace = ws,
			follow = false,
		}))
	end

	hl.dispatch(hl.dsp.focus({ window = win }))
end

local close_win = function()
	local active = hl.get_active_window()

	if active ~= nil and active.class == file_explorer.class then
		toggle_file_explorer()
	else
		hl.dispatch(hl.dsp.window.close())
	end
end

-- Global shortcuts
hl.bind(mainMod .. " + ALT + H", hl.dsp.global("quickshell:toggle"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.global("quickshell:lock"))
hl.bind(mainMod .. " + D", hl.dsp.global("quickshell:appLauncher"))
hl.bind(mainMod .. " + R", hl.dsp.global("quickshell:remote"))

-- Media controls
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("playerctl previous"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("playerctl next"))

-- Screenshots
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[grim -g "$(slurp -d)" - | wl-copy]]))

-- Apps
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", close_win)
hl.bind(mainMod .. " + ALT + N", hl.dsp.exec_cmd("zen-twilight"))
hl.bind(mainMod .. " + E", toggle_file_explorer)
hl.bind(
	mainMod .. " + ALT + D",
	hl.dsp.exec_cmd(terminal .. " -e sh nvim ~/tmp/notes/daily-$(date +%d-%b-%Y).md", { float = true })
)
hl.bind(mainMod .. " + ALT + G", input.swap_lalt_lwin)

-- Special workspaces
hl.bind(mainMod .. " + semicolon", hl.dsp.workspace.toggle_special("sagepopup"))
hl.bind(mainMod .. " + apostrophe", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mainMod .. " + CTRL + apostrophe", hl.dsp.window.move({ workspace = "special:scratch" }))
hl.bind(mainMod .. " + slash", hl.dsp.workspace.toggle_special("junk"))
hl.bind(mainMod .. " + CTRL + slash", hl.dsp.window.move({ workspace = "special:junk", silent = true }))
hl.bind(mainMod .. " + period", hl.dsp.workspace.toggle_special("multitasking"))
hl.bind(mainMod .. " + CTRL + period", hl.dsp.window.move({ workspace = "special:multitasking", silent = true }))

-- Window management
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Z", hl.dsp.layout("togglesplit"))

-- Focus movement
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.focus({ direction = "d" }))

-- Workspace switching
hl.bind(mainMod .. " + H", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ workspace = "e+1" }))

for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + U", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + I", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + O", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + P", hl.dsp.focus({ workspace = 4 }))

hl.bind(mainMod .. " + CTRL + U", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + CTRL + I", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + CTRL + O", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.focus({ workspace = 4 }))

-- Move window by direction
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "r" }))

-- Move window to relative workspace
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ workspace = "+1" }))

-- Mouse workspace scrolling
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse window manipulation
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys (locked + repeating)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -d " .. config.brightness.monitor .. " set +10%"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -d " .. config.brightness.monitor .. " set 10%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86KbdBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -d " .. config.brightness.keyboard .. " set +1"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86KbdBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -d " .. config.brightness.keyboard .. " set 1-"),
	{ locked = true, repeating = true }
)
