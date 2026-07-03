--[[
  ▄  ▌ ▐·▪  • ▌ ▄ ·.      ▄▄·        ▐ ▄ ·▄▄▄▪   ▄▄ •
•█▌▐█▪█·█▌██ ·██ ▐███▪    ▐█ ▌▪▪     •█▌▐█▐▄▄·██ ▐█ ▀ ▪
▐█▐▐▌▐█▐█•▐█·▐█ ▌▐▌▐█·    ██ ▄▄ ▄█▀▄ ▐█▐▐▌██▪ ▐█·▄█ ▀█▄
██▐█▌ ███ ▐█▌██ ██▌▐█▌    ▐███▌▐█▌.▐▌██▐█▌██▌.▐█▌▐█▄▪▐█
▀▀ █▪. ▀  ▀▀▀▀▀  █▪▀▀▀    ·▀▀▀  ▀█▄▀▪▀▀ █▪▀▀▀ ▀▀▀·▀▀▀▀
--]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.pack.add({
	-- Nice to have / dependencies
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/numToStr/Comment.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/folke/snacks.nvim", -- Used for images
	{ src = "https://github.com/lukas-reineke/indent-blankline.nvim", main = "ibl" },
	{ src = "https://github.com/folke/todo-comments.nvim", event = "VimEnter" },
	"https://github.com/stevearc/oil.nvim",

	-- Fuzzy finder
	"https://github.com/dmtrKovalenko/fff.nvim",

	-- Harpoon
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },

	-- Theme
	"https://github.com/rose-pine/neovim",
	"https://github.com/scottmckendry/cyberdream.nvim",
	"https://github.com/initsyscall/themeInitNvim",

	-- LSP
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/j-hui/fidget.nvim",
	{ src = "https://github.com/folke/lazydev.nvim", ft = "lua" },
	{ src = "https://github.com/saghen/blink.cmp", version = "v1" },
	"https://github.com/stevearc/conform.nvim",

	-- Telescope
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-ui-select.nvim",

	-- Visual cosmetics
	"https://github.com/nvim-tree/nvim-web-devicons",
	{
		src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "vimwiki", "codecompanion", "drunkdriver" },
	},
	{
		src = "https://github.com/iamcco/markdown-preview.nvim",
		ft = { "markdown" },
	},

	-- AI slop
	"https://github.com/github/copilot.vim",
	{
		src = "https://www.github.com/olimorris/codecompanion.nvim",
		version = vim.version.range("^19.0.0"),
	},
})

vim.g.mkdp_filetypes = { "markdown" }

require("settings")
require("keymaps")
require("autocommands")
require("status-line")

require("hex_colorizer")

require("plugins.lsp")

require("plugins.plugins")

require("plugins.codecompanion")
require("codecompanion-commands")

-- rose-pine theme
require("rose-pine").setup({
	styles = {
		italic = false,
	},
})
vim.cmd("colorscheme nightSyscall")

-- Better visual panes separation -> must be called at end
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#f578d1", bg = "NONE" })

-- The line beneath this is called `modeline`. See `:help modeline`
