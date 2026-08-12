local config = require("config")

local startup = {
	"hyprctl setcursor Bibata-Modern-Classic 22",
	"systemctl --user restart quickshell.service",
}

hl.on("hyprland.start", function()
	for _, cmd in pairs(startup) do
		hl.exec_cmd(cmd)
	end

	for _, cmd in pairs(config.startup) do
		hl.exec_cmd(cmd)
	end
end)
