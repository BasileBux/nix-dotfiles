local namespace = vim.api.nvim_create_namespace("HexColorizer")
local is_enabled = true

-- Helper to determine contrast color
local function get_fg_color(hex)
	local r = tonumber(hex:sub(2, 3), 16)
	local g = tonumber(hex:sub(4, 5), 16)
	local b = tonumber(hex:sub(6, 7), 16)

	local luminance = (0.299 * r + 0.587 * g + 0.114 * b)

	if luminance > 128 then
		return "#000000" -- Black text for light backgrounds
	else
		return "#ffffff" -- White text for dark backgrounds
	end
end

local function colorize_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	if not is_enabled then
		return
	end
	vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

	for i, line in ipairs(lines) do
		for hex in line:gmatch("(#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])") do
			local start_col = line:find(hex, 1, true) - 1
			local end_col = start_col + 7
			local hl_group = "HexColor_" .. hex:sub(2)

			local fg_color = get_fg_color(hex)
			vim.api.nvim_set_hl(0, hl_group, { bg = hex, fg = fg_color })

			vim.api.nvim_buf_set_extmark(bufnr, namespace, i - 1, start_col, {
				end_col = end_col,
				hl_group = hl_group,
			})
		end
	end
end

vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
	pattern = "*",
	callback = function()
		colorize_buffer()
	end,
})

vim.api.nvim_create_user_command("HexColorizerEnable", function()
  is_enabled = true
  colorize_buffer()
end, {})

vim.api.nvim_create_user_command("HexColorizerDisable", function()
  is_enabled = false
  colorize_buffer() -- Calling it when disabled clears the namespace
end, {})

vim.api.nvim_create_user_command("HexColorizerToggle", function()
  is_enabled = not is_enabled
  colorize_buffer()
end, {})
