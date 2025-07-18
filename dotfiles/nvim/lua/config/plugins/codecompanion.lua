return {
	{
		"olimorris/codecompanion.nvim",
		config = function()
			require("codecompanion").setup({
				-- Owned: gemini, anthropic, copilot
				adapters = {
					anthropic = function()
						return require("codecompanion.adapters").extend("anthropic", {
							name = "anthropic_cheaper",
							schema = {
								model = {
									default = "claude-3-5-sonnet-20241022",
								},
							},
						})
					end,

					gemini = function()
						return require("codecompanion.adapters").extend("gemini", {
							name = "gemini_better",
							schema = {
								model = {
									default = "gemini-2.5-pro-preview-03-25",
								},
							},
						})
					end,

					copilot = function()
						return require("codecompanion.adapters").extend("copilot", {
							name = "copilot",
							schema = {
								model = {
									-- default = "claude-3.7-sonnet-thought",
									-- default = "claude-3.7-sonnet",
									default = "claude-sonnet-4",
									-- default = "claude-3.5-sonnet",
									-- default = "gpt-4o-2024-08-06",
									-- default = "o1-2024-12-17",
									-- default = "o3-mini-2025-01-31",
									-- default = "o1-mini-2024-09-12",
									-- default = "gemini-2.0-flash-001",
									-- default = "gemini-2.5-pro",
								},
							},
						})
					end,
				},

				strategies = {
					-- Copilot uses claude-3.5-sonnet which has a small context window.
					-- For bigger context windows, use default model (4o) or directly use
					-- Anthropic adapter (which defaults to 3.5-sonnet for cost reasons).

					-- Available: "copilot", "anthropic", "gemini", "openai"
					chat = {
						adapter = "copilot", -- basically free
						-- adapter = "gemini",
					},
					inline = {
						adapter = "copilot",
					},
				},
				display = {
					chat = {
						show_settings = false, -- Set to true to show settings in chat
					},
				},
				opts = {
				},
			})
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	},
}
