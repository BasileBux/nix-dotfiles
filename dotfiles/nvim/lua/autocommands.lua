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

-- Auto-resize splits when Vim window is resized
autocmd("VimResized", {
	pattern = "*",
	command = "wincmd =",
})

-- Automatically reload files changed outside of Neovim
autocmd({ "FocusGained", "BufEnter" }, {
	pattern = "*",
	command = "checktime",
})

-- Disable treesitter-based syntax highlighting for certain filetypes
local no_treesitter_highlight = {
	"typescript",
}
vim.treesitter.language.register("qmljs", "qml")

-- Enable treesitter-based syntax highlighting if a parser is available for the filetype
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local ft = vim.bo.filetype
		if
			vim.treesitter.get_parser(0, ft, { error = false }) and not vim.tbl_contains(no_treesitter_highlight, ft)
		then
			vim.treesitter.start()
			vim.bo.syntax = "off"
		end
	end,
})

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
			if not ev.data.active then
				vim.cmd.packadd("fff.nvim")
			end
			require("fff.download").download_or_build_binary()
		elseif name == "blink.cmp" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("blink.cmp")
			end
			vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path })
		elseif name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("telescope-fzf-native.nvim")
			end
			vim.system({ "make" }, { cwd = ev.data.path })
		elseif name == "markdown-preview.nvim" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("markdown-preview.nvim")
			end
			vim.system({ "cd", "app", "&&", "npm", "install" }, { cwd = ev.data.path })
		end
	end,
})

-- Remove trailing spaces on save
local trim_trailing = augroup("TrimTrailingWhitespace", { clear = true })
autocmd("BufWritePre", {
	group = trim_trailing,
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getcurpos()
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})
