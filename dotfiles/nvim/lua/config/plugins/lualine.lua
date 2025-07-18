-- colorscheme for lualine
local bubblegum_colors = {
	blue = "#80a0ff",
	cyan = "#79dac8",
	black = "#080808",
	white = "#c6c6c6",
	red = "#ff5189",
	violet = "#d183e8",
	grey = "#303030",
	dark_grey = "#0f1419",
}

local dim_colors = {
	blue = "#002699",
	cyan = "#217868",
	black = "#080808",
	white = "#c6c6c6",
	red = "#990030",
	violet = "#691881",
	grey = "#303030",
	dark_grey = "#0f1419",
}

local obscure = {
	blue = "#6a8cbc",
	cyan = "#85b5ba",
	black = "#080808",
	white = "#c9c7cd",
	red = "#c45570",
	violet = "#b882a5",
	grey = "#303030",
	dark_grey = "#0f1419",
}

local colors = obscure

local lualine_theme = {
	normal = {
		a = { fg = colors.black, bg = colors.violet },
		-- b = { fg = colors.white, bg = colors.grey },
		b = { fg = colors.white, bg = colors.dark_grey },
		c = { fg = colors.white, bg = colors.dark_grey },
	},

	insert = { a = { fg = colors.black, bg = colors.cyan } },
	visual = { a = { fg = colors.black, bg = colors.blue } },
	replace = { a = { fg = colors.black, bg = colors.red } },

	inactive = {
		a = { fg = colors.white, bg = colors.black },
		b = { fg = colors.white, bg = colors.black },
		c = { fg = colors.white, bg = colors.black },
	},
}

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = lualine_theme,
				-- theme = "tokyonight-moon",
				component_separators = "",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
				-- lualine_b = { "filename", "branch" },
				lualine_b = { "filename" },
				lualine_c = {
					"%=", --[[ add your center compoentnts here in place of this comment ]]
				},
				lualine_x = {},
				-- lualine_y = { "filetype", "progress", "location" },
				lualine_y = { "progress", "location" },
				lualine_z = {},
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			tabline = {},
			extensions = {},
		},
	},
}
