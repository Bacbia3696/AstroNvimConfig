local M = {}

function M.config()
	require("neoclip").setup({
		history = 200,
		enable_persistent_history = true,
		continious_sync = false,
		db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
		filter = nil,
		preview = true,
		default_register = '"',
		default_register_macros = "q",
		enable_macro_history = true,
		content_spec_column = false,
		on_paste = {
			set_reg = false,
		},
		on_replay = {
			set_reg = false,
		},
		keys = {
			telescope = {
				i = {
					paste = "<c-y>",
					paste_behind = "<cr>",
					replay = "<c-q>", -- replay a macro
					delete = "<c-d>", -- delete an entry
					custom = {},
				},
				n = {
					paste = "p",
					paste_behind = "<cr>",
					replay = "q",
					delete = "d",
					custom = {},
				},
			},
		},
	})
end

return M
