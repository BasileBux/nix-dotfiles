require("settings")
require("keymaps")

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	group = highlight_group,
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 75 })
	end,
})
vim.opt.laststatus = 0
vim.opt.scrolloff = 5
