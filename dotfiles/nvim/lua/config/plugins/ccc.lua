return {
	{
		"uga-rosa/ccc.nvim", -- Specify the plugin repository
		config = function()
			local ccc = require("ccc")
			local mapping = ccc.mapping

			ccc.setup({
				-- Your preferred settings
				highlighter = {
					auto_enable = true,
					lsp = true,
				},
			})
		end,
	},
}
