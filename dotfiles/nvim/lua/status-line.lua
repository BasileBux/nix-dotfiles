local state = {
	full_path = false,
}

local modes = {
	["n"] = "NORMAL",
	["no"] = "NORMAL",
	["v"] = "VISUAL",
	["V"] = "VISUAL LINE",
	[""] = "VISUAL BLOCK",
	["s"] = "SELECT",
	["S"] = "SELECT LINE",
	[""] = "SELECT BLOCK",
	["i"] = "INSERT",
	["ic"] = "INSERT",
	["R"] = "REPLACE",
	["Rv"] = "VISUAL REPLACE",
	["c"] = "COMMAND",
	["cv"] = "VIM EX",
	["ce"] = "EX",
	["r"] = "PROMPT",
	["rm"] = "MOAR",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	["t"] = "TERMINAL",
}

local mode_colors = {
	n = "%#WarningMsg#",
	i = "%#ErrorMsg#",
	v = "%#MoreMsg#",
	V = "%#MoreMsg#",
	[""] = "%#MoreMsg#",
}

local function update_mode_colors()
	local m = vim.api.nvim_get_mode().mode
	return mode_colors[m] or "%#StatusLine#"
end

Statusline = {}

function Statusline.active()
    local win_width = vim.api.nvim_win_get_width(0)

    local m = modes[vim.api.nvim_get_mode().mode] or ""
    local label = string.format(" %-10s ", m)

    -- Left side: space + filename + modified flag (estimate rendered length)
    local filepath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), state.full_path and ":p" or ":.")
    local modified = vim.bo.modified and " [+]" or ""
    local left = " " .. filepath .. modified
    local left_len = #left

    -- Right side: " 100% 42:80 [lua] " — estimate
    local right = string.format(" %d%%  %d:%d %s ",
        math.floor(vim.fn.line(".") / vim.fn.line("$") * 100),
        vim.fn.line("."),
        vim.fn.col("."),
        vim.bo.filetype ~= "" and "[" .. vim.bo.filetype .. "]" or ""
    )
    local right_len = #right

    local label_len = #label
    local center_col = math.floor(win_width / 2)
    local label_start = center_col - math.floor(label_len / 2)

    local left_pad  = math.max(0, label_start - left_len)
    local right_pad = math.max(0, win_width - label_start - label_len - right_len)

    local color = update_mode_colors()

    return table.concat({
        left,
        string.rep(" ", left_pad),
        color,
        label,
        "%#StatusLine#",
        string.rep(" ", right_pad),
        right,
    })
end

function Statusline.inactive()
	return " %t"
end

function Statusline.toggle_path()
	state.full_path = not state.full_path
	vim.cmd("redrawstatus")
end

vim.keymap.set("n", "<leader>sp", function()
	Statusline.toggle_path()
end, { desc = "Toggle statusline path" })

function Statusline.render()
	if vim.g.statusline_winid == vim.api.nvim_get_current_win() then
		return Statusline.active()
	else
		return Statusline.inactive()
	end
end

vim.o.statusline = "%!v:lua.Statusline.render()"
