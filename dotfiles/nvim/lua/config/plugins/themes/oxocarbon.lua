return {
	{
		"nyoom-engineering/oxocarbon.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		config = function()
			vim.cmd.colorscheme("oxocarbon")
			-- vim.opt.background = "light" -- Light theme is acturally really good
		end,
	},
}
