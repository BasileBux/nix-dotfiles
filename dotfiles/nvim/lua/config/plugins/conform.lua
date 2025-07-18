return {
	{ -- Autoformat
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			-- Comment following function to disable formatting on save
			-- format_on_save = function(bufnr)
			-- 	-- Disable "format_on_save lsp_fallback" for languages that don't
			-- 	-- have a well standardized coding style. You can add additional
			-- 	-- languages here or re-enable it for the disabled ones.
			-- 	local disable_filetypes = { c = true, cpp = true, h = true, java = true }
			-- 	return {
			-- 		timeout_ms = 500,
			-- 		lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
			-- 	}
			-- end,
			formatters_by_ft = {
				lua = { "stylua" },
				css = { "prettier" },
				javascript = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				python = { "black" },
				markdown = { "markdownlint" },
				java = { "clang-format" },
				go = { "goimports" },
			},
		},
	},
}
