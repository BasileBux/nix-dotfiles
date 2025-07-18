-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Go back to normal
vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("i", "jj", "<Esc>")

-- Insert line above
vim.keymap.set("n", "OO", "o<esc>")

-- Move between tabs with ctrl + <jk>
vim.keymap.set({ "n", "i" }, "<C-j>", "<cmd>tabprevious<CR>")
vim.keymap.set({ "n", "i" }, "<C-k>", "<cmd>tabnext<CR>")

-- Move tabs to reorganize them
vim.keymap.set("n", "<C-A-j>", "<cmd>tabm -1<CR>")
vim.keymap.set("n", "<C-A-k>", "<cmd>tabm +1<CR>")

vim.keymap.set("n", "<space>t", "<cmd>tabnew<CR>")

vim.keymap.set("n", "<space>v", "<cmd>vsplit<CR>")
vim.keymap.set("n", "<space>s", "<cmd>split<CR>")

vim.keymap.set("n", "<space>d", vim.diagnostic.open_float)

-- Move between splits with shift + <hjkl>
vim.keymap.set("n", "<S-h>", "<cmd>wincmd h<CR>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<S-l>", "<cmd>wincmd l<CR>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<S-j>", "<cmd>wincmd j<CR>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<S-k>", "<cmd>wincmd k<CR>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<A-h>", "<cmd>cprev<CR>", { desc = "Go to previous element in quickfix list" })
vim.keymap.set("n", "<A-l>", "<cmd>cnext<CR>", { desc = "Go to previous element in quickfix list" })

vim.keymap.set("n", "<space>ff", "<cmd>Ex<CR>")

vim.keymap.set({ "n", "i", "v" }, "<A-j>", "<cmd>m+1<cr>")
vim.keymap.set({ "n", "i", "v" }, "<A-k>", "<cmd>m-2<cr>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- vim.keymap.set({ "n", "i", "v" }, "<leader>m", "<cmd>!make<CR>", { desc = "Make" })

vim.keymap.set("n", "<leader>m", function()
	vim.fn.system("make")
	local success = vim.v.shell_error == 0
	if success then
		vim.notify("Make: Success", vim.log.levels.INFO, { title = "Make" })
	else
		vim.notify("Make: Failed", vim.log.levels.ERROR, { title = "Make" })
	end
end, { desc = "Make" })
