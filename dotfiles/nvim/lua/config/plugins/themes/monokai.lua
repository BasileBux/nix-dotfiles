return {
	{
		"loctvl842/monokai-pro.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		opts = {
			-- transparent_background = true,
			-- transparent = true,
		},
		config = function()
			vim.cmd.colorscheme("monokai-pro")

			vim.cmd.hi("Comment gui=none")
		end,
	},
}
