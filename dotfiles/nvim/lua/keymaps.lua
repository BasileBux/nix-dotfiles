-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Go back to normal
vim.keymap.set("i", "kj", "<Esc>")

vim.keymap.set("n", "<leader>v", "<cmd>vsplit<CR>")
vim.keymap.set("n", "<leader>s", "<cmd>split<CR>")

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float) -- NOTE: might need to be moved to lsp.lua

-- Move between splits with shift + <hjkl>
vim.keymap.set("n", "<S-h>", "<cmd>wincmd h<CR>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<S-l>", "<cmd>wincmd l<CR>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<S-j>", "<cmd>wincmd j<CR>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<S-k>", "<cmd>wincmd k<CR>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<A-h>", "<cmd>cprev<CR>", { desc = "Go to previous element in quickfix list" })
vim.keymap.set("n", "<A-l>", "<cmd>cnext<CR>", { desc = "Go to previous element in quickfix list" })

vim.keymap.set({ "n", "i", "v" }, "<A-j>", "<cmd>m+1<cr>")
vim.keymap.set({ "n", "i", "v" }, "<A-k>", "<cmd>m-2<cr>")

-- Diagnostic keymaps -- NOTE: might need to be moved to lsp.lua
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-]>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
