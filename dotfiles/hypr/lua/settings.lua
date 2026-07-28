local fe = {
	nemo = {
		cmd = "nemo",
		class = "nemo",
	},
	nautilus = {
		cmd = "nautilus",
		class = "org.gnome.Nautilus",
	},
}

return {
	file_explorers = fe,
	file_explorer = fe.nemo,
	browser = os.getenv("WEB_BROWSER") or "zen-twilight",
}
