return {
	numhl = true,
	signcolumn = false,
	current_line_blame = true,
	current_line_blame_formatter_opts = {
		relative_time = true,
	},
	on_attach = function(bufnr)
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]g", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
		map("n", "[g", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })
		-- Actions
		-- Text object
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
	end,
}
