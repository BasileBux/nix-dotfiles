-- [[ Basic Autocommands ]]

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = highlight_group,
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 75 })
  end
})

-- Remove trailing whitespace on save
-- autocmd('BufWritePre', {
--   pattern = '',
--   command = '%s/\\s\\+$//e'
-- })

-- Auto-resize splits when Vim window is resized
autocmd('VimResized', {
  pattern = '*',
  command = 'wincmd ='
})

-- Automatically reload files changed outside of Neovim
autocmd({ 'FocusGained', 'BufEnter' }, {
  pattern = '*',
  command = 'checktime'
})

-- Set indent settings for specific file types
autocmd('FileType', {
  pattern = { 'c', 'cpp', 'h', 'hpp', 'cc', 'hh' },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
  end
})

-- Automatically insert newlines in markdown instead of wrapping
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   callback = function()
--     vim.opt_local.textwidth = 80
--     vim.opt_local.formatoptions:append('a')
--   end
-- })


-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = "*.tex",
--   callback = function()
--     vim.fn.jobstart("make", {
--       detach = true,
--       on_exit = function(_, exit_code)
--         if exit_code ~= 0 then
--           vim.notify("Make failed with exit code: " .. exit_code, vim.log.levels.ERROR)
--         else
--           vim.notify("Make successful", vim.log.levels.INFO)
--         end
--       end
--     })
--   end,
--   desc = "Run make command after saving .tex files in background"
-- })
