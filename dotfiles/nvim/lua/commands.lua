local dir = "/.codecompanion-chat"

vim.api.nvim_create_user_command("SaveChat", function()
	if vim.bo.filetype ~= "codecompanion" then
		vim.notify("This command can only be used in CodeCompanion chat", vim.log.levels.ERROR)
		return
	end

	local save_dir = vim.fn.getcwd() .. dir
	if vim.fn.isdirectory(save_dir) == 0 then
		vim.fn.mkdir(save_dir, "p")

		-- Recursive gitignore
		local gitignore_path = save_dir .. "/.gitignore"
		vim.fn.writefile({ "*" }, gitignore_path)
	end

	-- Prompt for title
	vim.ui.input({
		prompt = "Enter chat title: ",
		default = "",
	}, function(title)
		if not title or title == "" then
			vim.notify("Save cancelled", vim.log.levels.WARN)
			return
		end
		-- Replace spaces with underscores and remove special characters
		title = title:gsub("%s+", "_"):gsub("[^%w_-]", "")
		local filename = os.date("%d%m%y") .. "_" .. title .. ".md"
		local filepath = save_dir .. "/" .. filename

		local success = vim.cmd("write! " .. filepath)

		if success then
			vim.notify("Chat saved to " .. filepath, vim.log.levels.INFO)
		end
	end)
end, {})

vim.api.nvim_create_user_command("LoadChat", function()
	if vim.bo.filetype ~= "codecompanion" then
		vim.notify("This command can only be used in CodeCompanion chat", vim.log.levels.ERROR)
		return
	end

	local save_dir = vim.fn.getcwd() .. dir

	if vim.fn.isdirectory(save_dir) == 0 then
		vim.notify("No codecompanion directory found", vim.log.levels.ERROR)
		return
	end

	-- Get all chat files
	local files = vim.fn.globpath(save_dir, "*.md", false, true)
	if #files == 0 then
		vim.notify("No saved chats found", vim.log.levels.ERROR)
		return
	end

	-- Create table with file info for sorting
	local file_info = {}
	for _, file in ipairs(files) do
		local filename = vim.fn.fnamemodify(file, ":t")
		-- Extract date and title
		local date_str, title = filename:match("(%d%d%d%d%d%d)_(.+)%.md$")
		if date_str and title then
			table.insert(file_info, {
				filename = filename,
				date_str = date_str,
				title = title:gsub("_", " "),
				full_path = file,
			})
		end
	end

	-- Sort by date (newest first)
	table.sort(file_info, function(a, b)
		return a.date_str > b.date_str
	end)

	-- Format for display
	local formatted_items = {}
	local file_lookup = {}
	for _, info in ipairs(file_info) do
		local display_text = string.format(
			"%s - %s",
			os.date("%d/%m/%y", tonumber(info.date_str:match("(%d%d)(%d%d)(%d%d)"))),
			info.title
		)
		table.insert(formatted_items, display_text)
		file_lookup[display_text] = info.full_path
	end

	vim.ui.select(formatted_items, {
		prompt = "Select chat to load:",
		format_item = function(item)
			return item
		end,
	}, function(choice)
		if choice then
			local filepath = file_lookup[choice]
			local content = vim.fn.readfile(filepath)
			local bufnr = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
			vim.notify("Chat loaded from " .. filepath, vim.log.levels.INFO)
		end
	end)
end, {})

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

vim.api.nvim_create_user_command("Prompts", function()
	local prompts_dir = vim.fn.expand("~/prompts")
	if vim.fn.isdirectory(prompts_dir) == 0 then
		vim.notify("No prompts directory found", vim.log.levels.ERROR)
		return
	end

	local files = vim.fn.globpath(prompts_dir, "*", false, true)
	if #files == 0 then
		vim.notify("No prompts found", vim.log.levels.ERROR)
		return
	end

	-- Format filenames for display
	local formatted_items = {}
	local file_lookup = {}
	for _, file in ipairs(files) do
		local filename = vim.fn.fnamemodify(file, ":t")
		table.insert(formatted_items, filename)
		file_lookup[filename] = file
	end

	-- Sort alphabetically
	table.sort(formatted_items)

	vim.ui.select(formatted_items, {
		prompt = "Select prompt to copy:",
		format_item = function(item)
			return item
		end,
	}, function(choice)
		if choice then
			local filepath = file_lookup[choice]
			local content = table.concat(vim.fn.readfile(filepath), "\n")
			-- vim.fn.setreg('"', content) -- If system clipboard != unnamed register
			vim.fn.setreg('+', content) -- If system clipboard == unnamed register
			vim.notify("Prompt copied to clipboard", vim.log.levels.INFO)
		end
	end)
end, {})

-- Variable to store the window ID of the active shell script window
local current_shell_win_id = nil

vim.api.nvim_create_user_command("Shell", function()
	-- Check if a valid shell window already exists and focus it
	if current_shell_win_id and vim.api.nvim_win_is_valid(current_shell_win_id) then
		vim.api.nvim_set_current_win(current_shell_win_id)
		return
	end
	-- Reset in case the previous ID was invalid
	current_shell_win_id = nil

	-- Store the original CWD to set it for the floating window
	local original_cwd = vim.fn.getcwd()
	-- Define the path for the temporary script, but don't create it yet
	local temp_script_path = vim.fn.tempname()

	-- Function to display output in a floating window
	local function display_output(lines)
		local output_bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, lines)
		vim.api.nvim_buf_set_option(output_bufnr, "bufhidden", "wipe")
		vim.api.nvim_buf_set_option(output_bufnr, "buftype", "nofile")
		vim.api.nvim_buf_set_option(output_bufnr, "swapfile", false)
		vim.api.nvim_buf_set_option(output_bufnr, "modifiable", false) -- Make it read-only *after* setting content

		local width = vim.api.nvim_get_option("columns")
		local height = vim.api.nvim_get_option("lines")
		local win_width = math.floor(width * 0.8)
		local win_height = math.floor(height * 0.6)
		local row = math.floor((height - win_height) / 2)
		local col = math.floor((width - win_width) / 2)

		local border_opts = {
			border = "rounded",
			style = "minimal",
			title = "Script Output",
			title_pos = "center",
		}

		local output_win_id = vim.api.nvim_open_win(output_bufnr, true, {
			relative = "editor",
			width = win_width,
			height = win_height,
			row = row,
			col = col,
			border = border_opts.border,
			style = border_opts.style,
			title = border_opts.title,
			title_pos = border_opts.title_pos,
		})

		-- Close output window with 'q'
		vim.api.nvim_buf_set_keymap(
			output_bufnr,
			"n",
			"q",
			"<Cmd>close<CR>",
			{ noremap = true, silent = true, nowait = true }
		)
	end

	-- 2. Create Buffer and Floating Window for the script
	local script_bufnr = vim.api.nvim_create_buf(false, true) -- Create a listed buffer
	-- Set a placeholder name, not the temp file path
	vim.api.nvim_buf_set_name(script_bufnr, "temp_shell_script.sh")
	-- Set initial content directly
	vim.api.nvim_buf_set_lines(script_bufnr, 0, -1, false, { "#!/bin/bash", "" })
	-- Set buffer options
	vim.api.nvim_buf_set_option(script_bufnr, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(script_bufnr, "swapfile", false)
	vim.bo[script_bufnr].filetype = "sh" -- Set filetype for syntax highlighting etc.

	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")
	local win_width = math.floor(width * 0.6)
	local win_height = math.floor(height * 0.5)
	local row = math.floor((height - win_height) / 4) -- Position slightly higher
	local col = math.floor((width - win_width) / 2)

	local border_opts = {
		border = "rounded",
		style = "minimal",
		title = "Temporary Shell Script",
		title_pos = "center",
	}

	local script_win_id = vim.api.nvim_open_win(script_bufnr, true, {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		border = border_opts.border,
		style = border_opts.style,
		title = border_opts.title,
		title_pos = border_opts.title_pos,
		zindex = 1, -- Set a high z-index to keep it on top
	})
	current_shell_win_id = script_win_id

	-- Set the local working directory for the floating window
	-- Use fnameescape to handle potential special characters in the path
	vim.api.nvim_win_call(script_win_id, function()
		vim.cmd.lcd(vim.fn.fnameescape(original_cwd))
	end)

	-- 3. Map Enter Key in the script buffer
	vim.api.nvim_buf_set_keymap(
		script_bufnr,
		"n",
		"<CR>",
		"",
		{
			noremap = true,
			silent = true,
			callback = function()
				-- Get content and write to the actual temporary file
				local script_content = vim.api.nvim_buf_get_lines(script_bufnr, 0, -1, false)
				local write_ok = vim.fn.writefile(script_content, temp_script_path)
				if write_ok ~= 0 then
					vim.notify("Error writing temporary script file: " .. temp_script_path, vim.log.levels.ERROR)
					return
				end
				-- Make executable *after* writing
				vim.fn.setfperm(temp_script_path, "rwxr-xr-x")

				-- Execute the script
				local output_lines = {}
				local job_id = vim.fn.jobstart(temp_script_path, {
					stdout_buffered = true,
					stderr_buffered = true,
					on_stdout = function(_, data)
						if data then
							for _, line in ipairs(data) do
								if line ~= "" then
									table.insert(output_lines, line)
								end
							end
						end
					end,
					on_stderr = function(_, data)
						if data then
							table.insert(output_lines, "--- STDERR ---")
							for _, line in ipairs(data) do
								if line ~= "" then
									table.insert(output_lines, line)
								end
							end
						end
					end,
					on_exit = function(_, code)
						table.insert(output_lines, "--- EXIT CODE: " .. code .. " ---")
						-- Ensure execution happens in the main loop to avoid API errors
						vim.schedule(function()
							display_output(output_lines)
						end)
					end,
				})
				if job_id <= 0 then
					vim.notify("Failed to start job for script: " .. temp_script_path, vim.log.levels.ERROR)
				end
			end,
		}
	)

	-- 4. Cleanup: Delete the temp file when the buffer is wiped out
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = script_bufnr,
		once = true,
		callback = function()
			current_shell_win_id = nil
			if vim.fn.filereadable(temp_script_path) == 1 then
				vim.fn.delete(temp_script_path)
			end
		end,
	})
end, {})
