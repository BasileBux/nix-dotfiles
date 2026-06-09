local config = require("config")

local startup = {
	"dbus-update-activation-environment --systemd DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE",
	"systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target",
	"hyprctl setcursor Bibata-Modern-Classic 22",
	"pkill quickshell; quickshell",
	"systemctl --user start hyprpolkitagent",
}

hl.on("hyprland.start", function()
	for _, cmd in pairs(startup) do
		hl.exec_cmd(cmd)
	end

	for _, cmd in pairs(config.startup) do
		hl.exec_cmd(cmd)
	end
end)
