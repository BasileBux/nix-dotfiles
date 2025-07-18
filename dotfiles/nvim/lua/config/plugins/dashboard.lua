return {
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			local logo = [[
⠀⠀⢀⣤⣶⣶⣶⣶⣶⣶⣶⣤⠀⠀⠀
⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣆⠀
⢰⣾⣿⠛⠉⠙⣿⠛⠛⠛⢿⣿⣿⣿⡀
⣾⣿⠉⠀⢸⡇⠀⠀⢸⡇⠀⣿⠿⢹⣿
⣿⣿⠀⠀⠈⢡⡀⣀⣬⠁⠀⢉⣴⣾⣿
⢿⡿⣿⣶⣖⣀⣉⠉⠀⣰⣶⣿⡿⢿⠿
⠘⠃⠙⠛⠛⢛⣯⣀⣀⣟⡛⠛⠇⠘⠀
⠀⠀⣤⠒⣶⢊⣛⢛⣛⢋⠛⣶⢢⡄⠀
⠀⢸⣸⣿⠀⠀⠀⠀⠀⠀⠀⢻⣇⣸⠀
⠀⢸⣭⣿⣾⣷⣿⣾⣷⣿⣿⣾⣯⣽⠀
⠀⠀⠀⣿⣿⣿⡟⠛⣿⣿⣿⣿⡇⠀⠀
⠀⠀⠀⠉⣭⣿⣏⠀⣿⣿⣿⣭⠁⠀⠀

Despite everything, it's still you.
]]
			logo = string.rep("\n", 8) .. logo .. "\n\n"
			require("dashboard").setup({
				theme = "doom",
				config = {
					header = vim.split(logo, "\n"),
					center = {
						{ action = "Telescope find_files", desc = " Find File", icon = " ", key = "f" },
						{ action = "ene | startinsert", desc = " New file", icon = " ", key = "n" },
						{
							action = function()
								vim.api.nvim_input("<cmd>qa<cr>")
							end,
							desc = " Quit",
							icon = " ",
							key = "q",
						},
					},
				},
			})
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
	},
}
