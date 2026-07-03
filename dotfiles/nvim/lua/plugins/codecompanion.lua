require("codecompanion").setup({
	-- Owned: gemini, anthropic, copilot
	adapters = {
		http = {
			-- Custom moonshot adapter (OpenAI compatible)
			moonshot = function()
				return require("codecompanion.adapters").extend("openai_compatible", {
					name = "moonshot",
					formatted_name = "Moonshot",
					env = {
						api_key = "MOONSHOT_API_KEY",
						url = "https://api.moonshot.ai",
						chat_url = "/v1/chat/completions",
						models_endpoint = "/v1/models",
					},
					schema = {
						model = {
							default = "kimi-k2-0905-preview",
						},
					},
				})
			end,
			-- build.nvidia.com/models. Super slow but free and works
			nvidia = function()
				return require("codecompanion.adapters").extend("openai_compatible", {
					name = "nvidia",
					formatted_name = "NVIDIA",
					env = {
						api_key = "NVIDIA_API_KEY",
						url = "https://integrate.api.nvidia.com",
						chat_url = "/v1/chat/completions",
						models_endpoint = "/v1/models",
					},
					schema = {
						model = {
							default = "z-ai/glm-5.1",
						},
					},
				})
			end,
		},
	},

	interactions = {
		chat = {
			adapter = {
				name = "moonshot",
				model = "kimi-k2.6",
			},
			keymaps = {
				send = {
					modes = { n = "<CR>", i = "<C-CR>" },
					opts = {},
				},
			},
		},
	},
})
require("plugins.codecompanion-fidget-spinner"):init()
vim.api.nvim_set_keymap("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", { noremap = true, silent = true })
