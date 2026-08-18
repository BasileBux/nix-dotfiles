-- I mess up commands sometimes like :W instead of :w so I did this
vim.api.nvim_create_user_command("W", function()
	vim.cmd("w")
end, {})

vim.api.nvim_create_user_command("Q", function()
	vim.cmd("q")
end, {})

vim.api.nvim_create_user_command("Wq", function()
	vim.cmd("wq")
end, {})

vim.api.nvim_create_user_command("WQ", function()
	vim.cmd("wq")
end, {})
