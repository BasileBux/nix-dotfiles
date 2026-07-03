require("settings")
require("keymaps")

-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

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
vim.opt.scrolloff = 0

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
local kitty_pipe = os.getenv("KITTY_PIPE_DATA")
local input_line_number = os.getenv("INPUT_LINE_NUMER")
if kitty_pipe and input_line_number then
	-- KITTY_PIPE_DATA={scrolled_by}:{cursor_x},{cursor_y}:{lines},{columns}
	local _, cursor_x, cursor_y, term_lines = kitty_pipe:match("^(%d+):(%d+),(%d+):(%d+)")
	if cursor_x and cursor_y then
		local term_height = tonumber(term_lines)
		local scrolled_by = tonumber(input_line_number)
		local target_line = tonumber(cursor_y)
		local target_col = tonumber(cursor_x)

		local timer = nil

		local function init()
			if timer then
				timer:stop()
			end

			timer = vim.defer_fn(function()
				if term_height == target_line then
					vim.cmd("normal! Gkzb")
					vim.cmd(string.format("normal! 0%dl", target_col - 1))
				else
					vim.api.nvim_win_set_cursor(0, { scrolled_by + 1, 0 })
					vim.cmd("normal! zt")

					vim.cmd(string.format("normal! %dG%d|", target_line + scrolled_by, target_col))
				end
			end, 10)
		end

		vim.api.nvim_create_autocmd("TextChanged", {
			pattern = "*",
			once = true,
			callback = init,
		})
		init()
	end
end
