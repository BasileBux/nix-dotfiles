-- Function to clean up unused plugins
function PackClean()
	local unused = vim.iter(vim.pack.get())
		:filter(function(x)
			return not x.active
		end)
		:map(function(x)
			return x.spec.name
		end)
		:totable()

	if #unused == 0 then
		vim.notify("No unused plugins to remove.", vim.log.levels.INFO)
		return
	end

	vim.notify("Removing " .. #unused .. " unused plugin(s): " .. table.concat(unused, ", "), vim.log.levels.INFO)
	vim.pack.del(unused)
end

-- Oil.nvim
require("oil").setup({
	default_file_explorer = true,
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open oil file picker" })
vim.api.nvim_create_user_command("Ex", function()
	require("oil").open()
end, { desc = "Open the file explorer" })

-- fff.nvim
vim.g.fff = { prompt = "🦦 " }
vim.keymap.set("n", "<leader>ff", function()
	require("fff").find_files()
end, { desc = "Open file picker" })
vim.keymap.set("n", "<leader>sg", function()
	require("fff").live_grep()
end, { desc = "Open live grep picker" })

-- Harpoon
local harpoon = require("harpoon")
harpoon:setup()
vim.keymap.set("n", "<leader>t", function()
	harpoon:list():add()
end, { desc = "Add file to harpoon" })
vim.keymap.set("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
for i = 1, 9 do
	vim.keymap.set("n", "<leader>" .. i, function()
		harpoon:list():select(i)
	end, { desc = "Go to harpoon mark " .. i })
end
vim.keymap.set("n", "<C-j>", function()
	harpoon:list():prev()
end, { desc = "Previous harpoon file" })

vim.keymap.set("n", "<C-k>", function()
	harpoon:list():next()
end, { desc = "Next harpoon file" })

-- indent-blankline.nvim
require("ibl").setup({
	indent = {
		char = "│",
		tab_char = "│",
	},
	scope = {
		enabled = false,
	},
})

-- todo-comments.nvim
require("todo-comments").setup({
	signs = false,
	keywords = {
		WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX", "DEBUG" } },
	},
})

-- Render-markdown.nvim
require("render-markdown").setup({
	file_types = { "markdown", "vimwiki", "codecompanion" },
})

-- copilot.vim
vim.g.copilot_assume_mapped = true
vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<C-f>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.keymap.set("i", "<C-s>", 'copilot#AcceptWord("<CR>")', { silent = true, expr = true })

-- Telescope
require("telescope").setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown(),
		},
	},
})
pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "ui-select")
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>gss", builtin.git_status, { desc = "[G]it [S]tatus" })
