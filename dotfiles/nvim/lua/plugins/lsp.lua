local lsp_servers = {
	"lua_ls",
	"basedpyright",
	"cmake",
	"clangd",
	"gopls",
	-- "ltex", -- Anoying because it shows grammar errors but might be useful
	"nil_ls",
	"qmlls",
	"tinymist",
	"ts_ls",
	"rust_analyzer",
	"marksman",
	"bashls",
}

-- If we are in a PlatformIO project, we need to tell clangd to use the correct compiler
local function get_clangd_cmd()
	local cmd = { "clangd" }
	local root = vim.fs.root(0, { "compile_commands.json", ".clangd", "platformio.ini", ".git" })
	if root then
		local pio_ini = root .. "/platformio.ini"
		if vim.uv.fs_stat(pio_ini) then
			local home = vim.uv.os_homedir()
			table.insert(
				cmd,
				"--query-driver=" .. home .. "/.platformio/packages/toolchain-xtensa-esp32/bin/xtensa-esp32-elf-g++"
			)
		end
	end
	return cmd
end

vim.lsp.config("clangd", {
	cmd = get_clangd_cmd(),
	root_markers = { "compile_commands.json", ".clangd", "platformio.ini", ".git" },
})

vim.lsp.enable(lsp_servers)

local map = function(keys, func, desc, mode)
	mode = mode or "n"
	vim.keymap.set(mode, keys, func, { desc = "LSP: " .. desc })
end

map("<leader>h", vim.lsp.buf.hover, "[H]over Documentation")

map("gt", vim.lsp.buf.type_definition, "[G]oto [T]ype Definition")
map("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
map("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

map("rn", vim.lsp.buf.rename, "[R]e[n]ame")
map("ga", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

-- If we want to do something when an LSP server attaches to a buffer
-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(event) end,
-- })

require("fidget").setup({})

require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = false } }, -- ctrl + space to see docs
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	fuzzy = { implementation = "prefer_rust" },
})

-- Formatting
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		css = { "prettier" },
		javascript = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		arduino = { "clang-format" },
		java = { "clang-format" },
		go = { "gofmt" },
		xml = { "xmlformat" },
		nix = { "nixfmt" },
		typst = { "typstyle" },
	},
})
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end)

-- Specific to neovim Lua, to get LSP features in this config file
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})
