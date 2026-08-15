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

local watch_and_open_pdf = function()
	if vim.bo.filetype == "typst" and vim.env.XDG_SESSION_TYPE ~= nil then
		local file = vim.api.nvim_buf_get_name(0)
		vim.fn.jobstart({ "typst", "watch", file })
		local out_file = file:gsub("%.typ$", ".pdf")
		open_pdf(out_file)
	end
end

vim.api.nvim_create_user_command("Typst", function()
	watch_and_open_pdf()
end, {
	desc = "Watch the current typst file and opens the generated PDF",
})
