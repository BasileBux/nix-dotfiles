require("lazy").setup({
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

	-- "gc" to comment visual regions/lines
	{ "numToStr/Comment.nvim", opts = {} },

	require("config.plugins.gitsigns"),

	require("config.plugins.diffview"),

	require("config.plugins.telescope"),

	require("config.plugins.lspconfig"),

	require("config.plugins.conform"),

	require("config.plugins.cmp"),

	-- require("config.plugins.dap"), -- Configuration is bugged for some reason

	require("config.plugins.surround"),

	-- Themes
	-- require("config.plugins.themes.rose-pine"),
	-- require("config.plugins.themes.ayu"),
	-- require("config.plugins.themes.eidolon"),
	-- require("config.plugins.themes.hybrid"),
	-- require("config.plugins.themes.monokai"),
	-- require("config.plugins.themes.obscure"),
	-- require("config.plugins.themes.tokyonight"),
	-- require("config.plugins.themes.alabaster"),
	require("config.plugins.themes.oxocarbon"),

	require("config.plugins.todo-comments"),

	require("config.plugins.treesitter"),

	require("config.plugins.dashboard"),

	require("config.plugins.lualine"),

	require("config.plugins.markdown-preview"),

	require("config.plugins.render-markdown"),

	-- require("config.plugins.ccc"), -- configuration is bugged for some reason

	require("config.plugins.toggleterm"),

	require("config.plugins.copilot"),

	require("config.plugins.codecompanion"),

	require("config.plugins.avante"),

	-- require("config.plugins.mail"),
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
