-- orgmode
require("orgmode").setup({
	org_agenda_files = "~/orgfiles/**/*.org",
	org_default_notes_file = "~/orgfiles/refile.org",

	mappings = {
		global = {
			org_agenda = "<leader>a",
			org_capture = "<leader>c",
		},
	},

	org_agenda_hide_empty_blocks = true,
	org_agenda_custom_commands = {
		-- Sectioned TODO list, one block per :CATEGORY: defined as a top-level
		-- heading in ~/orgfiles/tasks.org, plus the refile.org inbox. Add a block
		-- here when adding a section.
		g = {
			description = "TODOs by section",
			types = {
				{
					type = "tags_todo",
					org_agenda_overriding_header = "School",
					org_agenda_category_filter_preset = "School",
				},
				{
					type = "tags_todo",
					org_agenda_overriding_header = "Personal",
					org_agenda_category_filter_preset = "Personal",
				},
				{
					type = "tags_todo",
					org_agenda_overriding_header = "Computers",
					org_agenda_category_filter_preset = "Computers",
				},
				{
					type = "tags_todo",
					org_agenda_overriding_header = "Refile",
					org_agenda_category_filter_preset = "refile",
				},
			},
		},
	},

	org_capture_templates = {
		t = {
			description = "Task",
			template = "* TODO %?\n  %u",
		},
		e = {
			description = "Event",
			template = "* %^{Event}\n  %^{Start}T--%^{End}t",
			properties = { empty_lines = { before = 1 } },
		},
	},

	org_todo_keywords = { "TODO", "WIP", "|", "DONE" },
	org_todo_keyword_faces = {
		WIP = ":foreground yellow :weight bold",
		DONE = ":foreground green",
	},
	win_split_mode = "horizontal",
})
vim.lsp.enable("org")
vim.api.nvim_set_hl(0, "@org.agenda.scheduled", { link = "Normal" })

vim.api.nvim_create_user_command("Refile", function()
	vim.cmd.edit("~/orgfiles/refile.org")
end, { desc = "Open refile.org inbox as a regular buffer" })
vim.keymap.set("n", "<leader>r", "<cmd>Inbox<cr>", { desc = "Open org inbox (refile.org)" })

-- `Todo`: the sectioned agenda view, full window. Everything below is just its
-- implementation detail: orgmode has no option to show deadlines in todo views,
-- so the helpers render them as right-aligned virtual text by hooking plugin
-- internals (may need fixing on plugin updates).

vim.api.nvim_create_user_command("Todo", function()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "orgagenda",
		once = true,
		callback = function()
			vim.schedule(function()
				vim.cmd("only")
			end)
		end,
	})
	vim.cmd("Org agenda g")
end, { desc = "Open local org TODO list by section, full window" })

local deadline_ns = vim.api.nvim_create_namespace("todo-deadlines")
local Date = require("orgmode.objects.date")
local AgendaDayType = require("orgmode.agenda.types.agenda")

local function deadline_text(deadline)
	local diff = deadline:diff(Date.today(), "day")
	local rel
	if diff == 0 then
		rel = "today"
	elseif diff == 1 then
		rel = "tomorrow"
	elseif diff == -1 then
		rel = "yesterday"
	elseif diff > 0 then
		rel = ("in %d days"):format(diff)
	else
		rel = ("%d days ago"):format(-diff)
	end
	return ("DL: %s (%s)"):format(deadline:format("%b %d"), rel)
end

local function add_deadline_extmarks()
	local agenda = require("orgmode").agenda
	local marks = {}
	local bufnr
	for _, view in ipairs(agenda.views) do
		if getmetatable(view) ~= AgendaDayType then
			bufnr = view.bufnr and view.bufnr > 0 and view.bufnr or vim.api.nvim_get_current_buf()
			for _, line in ipairs(view:get_lines()) do
				local headline = line.headline
				if headline and not headline:is_done() then
					local deadline = headline:get_deadline_date()
					if deadline then
						table.insert(marks, { line.line_nr - 1, deadline })
					end
				end
			end
		end
	end
	if not bufnr then
		return
	end
	vim.api.nvim_buf_clear_namespace(bufnr, deadline_ns, 0, -1)
	for _, mark in ipairs(marks) do
		local row, deadline = mark[1], mark[2]
		vim.api.nvim_buf_set_extmark(bufnr, deadline_ns, row, 0, {
			virt_text = {
				{
					deadline_text(deadline),
					deadline:is_before(Date.today(), "day") and "@org.agenda.scheduled_past" or "@org.agenda.deadline",
				},
			},
			virt_text_pos = "right_align",
		})
	end
end

local function hook_render(obj, method)
	local orig = obj[method]
	obj[method] = function(self, ...)
		local res = orig(self, ...)
		vim.schedule(add_deadline_extmarks)
		return res
	end
end
hook_render(require("orgmode").agenda, "render")
hook_render(require("orgmode.agenda.types.todo"), "rerender_agenda_line")
