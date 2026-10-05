local pdf_reader_command = "evince $f"

local open_pdf = function(filename)
	local parts = vim.split(pdf_reader_command, "%s+", { trimempty = true })
	for i, part in ipairs(parts) do
		if part == "$f" then
			parts[i] = filename
		end
	end
	vim.fn.jobstart(parts)
end

local is_ancestor = function(a, b)
	a = vim.fs.normalize(a)
	b = vim.fs.normalize(b)
	return b:sub(1, #a) == a and (b:len() == #a or b:sub(#a + 1, #a + 1) == "/")
end

local common_ancestor = function(a, b)
	while a and a ~= "/" do
		if a == b or is_ancestor(a, b) then
			return a
		end
		a = vim.fs.dirname(a)
	end
	return nil
end

-- Typst sandboxes file access to its --root (default: the parent dir of the
-- input file). Templates that import shared files from elsewhere (e.g.
-- `#import "../../template/main.typ"`) fail with:
--   path `"..." would escape the project root`
-- Instead of hardcoding a root, probe `typst compile`, parse those errors and
-- grow the root to the common ancestor of every escaping path. Works for any
-- template layout.
local compute_root = function(file)
	local dir = vim.fs.dirname(file)
	local out = file:gsub("%.typ$", ".pdf")
	local root = dir
	for _ = 1, 10 do
		local res = vim.system({ "typst", "compile", "--root", root, file, out }, { text = true }):wait()
		local escaped = res.stderr:match('path `"([^"]+)"` would escape the project root')
		if not escaped then
			return root
		end
		-- the escaping path is relative to the importing file's directory
		local esc_abs = vim.fs.normalize(dir .. "/" .. escaped)
		root = common_ancestor(root, vim.fs.dirname(esc_abs))
		if not root then
			return nil
		end
	end
	return root
end

local watch_and_open_pdf = function()
	if vim.bo.filetype == "typst" and vim.env.XDG_SESSION_TYPE ~= nil then
		local file = vim.api.nvim_buf_get_name(0)
		local root = compute_root(file)
		local cmd = { "typst", "watch", "--root", root, file }
		vim.fn.jobstart(cmd)
		local out_file = file:gsub("%.typ$", ".pdf")
		open_pdf(out_file)
	end
end

local generate_glossary = function()
	local text = vim.trim(vim.fn.getreg("+"))

	local long, short = text:match("^(.-)%s*%(([^()]+)%)$")
	if not long or long == "" then
		error('Clipboard does not match "Long Name (ABBR)": ' .. text)
	end

	local result = table.concat({
		"(",
		'  key: "' .. short:lower() .. '",',
		'  short: "' .. short .. '",',
		'  long: "' .. long .. '",',
		"),",
	}, "\n")

	vim.fn.setreg("+", result)
end

vim.api.nvim_create_user_command("Typst", function()
	watch_and_open_pdf()
end, {
	desc = "Watch the current typst file and opens the generated PDF",
})

vim.api.nvim_create_user_command("Gloss", function()
	generate_glossary()
end, {
	desc = "Takes something of the shape 'SecureMonitor Call (SMC)' from the clipboard and creates a glossary entry",
})
