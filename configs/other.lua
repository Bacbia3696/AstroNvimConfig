local M = {}

function M.config()
	local status_ok, other = pcall(require, "other-nvim")
	if not status_ok then
		return
	end

	other.setup({
		mappings = {
			{
				pattern = "/src/(.*)/index.tsx$",
				target = "/src/%1/style.scss",
			},
			{
				pattern = "/src/(.*)/style.scss",
				target = "/src/%1/index.tsx$",
			},
			{
				pattern = "/src/(.*).tsx$",
				target = "/src/%1.scss$",
			},
			{
				pattern = "/src/(.*).scss$",
				target = "/src/%1.tsx$",
			},
		},
	})

	vim.keymap.set("", "<space>ll", "<cmd>Other<CR>", { silent = true })
	vim.keymap.set("", "<space>lp", "<cmd>OtherSplit<CR>", { silent = true })
	vim.keymap.set("", "<space>lv", "<cmd>OtherVSplit<CR>", { silent = true })
	vim.keymap.set("", "<space>lc", "<cmd>OtherClear<CR>", { silent = true })
end

return M
