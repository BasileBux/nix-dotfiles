-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = "a"

vim.opt.showmode = false

-- Share clipboard with OS
vim.opt.clipboard = "unnamedplus"

vim.opt.breakindent = true

vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

vim.opt.undodir = "/home/basileb/.local/share/nvim/undo"

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"
-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.wrap = false
vim.opt.linebreak = true

-- line to keep code tidy
vim.opt.colorcolumn = "80"

-- Hide top comment in netrw
vim.g.netrw_banner = 0

vim.filetype.add({
  extension = {
    sage = "python",
  },
})
