return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		opts = {
			provider = "copilot",
			-- provider = "gemini",
			providers = {
				copilot = {
					-- model = "claude-3.5-sonnet",
					model = "claude-sonnet-4",
				},
				gemini = {
					model = "gemini-2.5-pro-preview-03-25",
				},
			},
			behaviour = {
				enable_token_counting = false,
			},
			windows = {
				width = 40,
			},
		},

		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "make BUILD_FROM_SOURCE=true",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			-- Needs either "github/copilot.vim" or "zbirenbaum/copilot.vim" to
			-- be installed for provider = "copilot"
			"MeanderingProgrammer/render-markdown.nvim",
		},
	},
}
