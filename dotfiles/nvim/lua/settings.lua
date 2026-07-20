-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = "a"

vim.opt.showmode = false

-- If running in an SSH session, use OSC 52 to share clipboard with OS
local function is_ssh()
  return os.getenv("SSH_TTY") ~= nil or os.getenv("SSH_CONNECTION") ~= nil
end

if is_ssh() then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

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

vim.opt.undodir = os.getenv("NVIM_UNDODIR")

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"
-- Show which line your cursor is on
vim.opt.cursorline = true

vim.opt.winborder = "rounded"

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.wrap = false
vim.opt.linebreak = true

-- line to keep code tidy
vim.opt.colorcolumn = "80"

vim.opt.termguicolors = true

-- Hide top comment in netrw
vim.g.netrw_banner = 0

vim.filetype.add({
	extension = {
		sage = "python",
	},
})

-- I much prefer 4 spaces tabs, but the Arduino IDE defaults to 2 spaces.
vim.g.arduino_recommended_style = 0
