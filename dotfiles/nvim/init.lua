--[[
 ▐ ▄  ▌ ▐·▪  • ▌ ▄ ·.      ▄▄·        ▐ ▄ ·▄▄▄▪   ▄▄ •
•█▌▐█▪█·█▌██ ·██ ▐███▪    ▐█ ▌▪▪     •█▌▐█▐▄▄·██ ▐█ ▀ ▪
▐█▐▐▌▐█▐█•▐█·▐█ ▌▐▌▐█·    ██ ▄▄ ▄█▀▄ ▐█▐▐▌██▪ ▐█·▄█ ▀█▄
██▐█▌ ███ ▐█▌██ ██▌▐█▌    ▐███▌▐█▌.▐▌██▐█▌██▌.▐█▌▐█▄▪▐█
▀▀ █▪. ▀  ▀▀▀▀▀  █▪▀▀▀    ·▀▀▀  ▀█▄▀▪▀▀ █▪▀▀▀ ▀▀▀·▀▀▀▀
--]]
--
-- Set <space> as the leader key
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

require("settings")

require("keymaps")

require("autocommands")

require("commands")

require("lazy-bootstrap")

require("lazy-plugins")

vim.opt.tabstop = 4

-- Better visual panes separation -> must be called at end
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#f578d1", bg = "NONE" })

-- The line beneath this is called `modeline`. See `:help modeline`
