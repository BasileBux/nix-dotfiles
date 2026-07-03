require("settings")
require("keymaps")

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight and exit on yank
local highlight_group = augroup("YankHighlight", { clear = true })
local highlight_timeout = 50
autocmd("TextYankPost", {
	group = highlight_group,
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = highlight_timeout })
		vim.defer_fn(function()
			os.exit(0)
		end, highlight_timeout)
	end,
})

vim.opt.laststatus = 0
vim.opt.showmode = false
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.cmdheight = 0

vim.opt.scrolloff = 0

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"

local function wait_for_stable_lines(callback, last_count, stable_count)
	last_count = last_count or -1
	stable_count = stable_count or 0

	vim.defer_fn(function()
		local count = vim.api.nvim_buf_line_count(0)
		if count == last_count then
			stable_count = stable_count + 1
		else
			stable_count = 0
		end

		if stable_count >= 2 then -- stable for 2 checks in a row
			callback()
		else
			wait_for_stable_lines(callback, count, stable_count)
		end
	end, 1)
end

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

		local function init()
			local file = vim.fn.expand("%:p")
			local data = table.concat(vim.fn.readfile(file, "b"), "\n")
			vim.cmd("enew")
			local chan = vim.api.nvim_open_term(0, {})
			vim.fn.chansend(chan, data)

			vim.api.nvim_create_autocmd("VimLeavePre", {
				once = true,
				callback = function()
					os.remove(file)
				end,
			})

			wait_for_stable_lines(function()
				if term_height == target_line then
					vim.cmd("normal! Gzb")
					vim.cmd(string.format("normal! 0%dl", target_col + 1))
				else
					vim.api.nvim_win_set_cursor(0, { scrolled_by + 1, 0 })
					vim.cmd("normal! zt")
					vim.cmd(string.format("normal! %dG%dl", target_line + scrolled_by, target_col))
				end
			end)
		end

		vim.api.nvim_create_autocmd("VimEnter", {
			pattern = "*",
			once = true,
			callback = init,
		})
	end
end
