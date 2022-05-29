local M = {}

function M.config()
	-- Formatting and linting
	-- https://github.com/jose-elias-alvarez/null-ls.nvim
	local status_ok, null_ls = pcall(require, "null-ls")
	if not status_ok then
		return
	end

	-- Check supported formatters
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
	local formatting = null_ls.builtins.formatting

	-- Check supported linters
	-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
	local diagnostics = null_ls.builtins.diagnostics

	null_ls.setup({
		debug = false,
    default_timeout = 5000,
		sources = {
			-- action from gitsigns
			-- null_ls.builtins.code_actions.gitsigns,
			-- Set a formatter
			formatting.prettier,
			formatting.black,
			formatting.goimports,
			formatting.shfmt.with({
				filetypes = { "sh", "zsh", "bash", "dockerfile" },
			}),
			formatting.sqlfluff,
			-- formatting.gofumpt,
			-- formatting.golines,
			formatting.stylua,
			formatting.buf,
			-- Set a linter
			diagnostics.golangci_lint,
			-- diagnostics.buf,
			diagnostics.sqlfluff,
		},
		-- NOTE: You can remove this on attach function to disable format on save
		---@diagnostic disable-next-line: unused-local
		on_attach = function(client)
			-- if client.resolved_capabilities.document_formatting then
			--   vim.cmd "autocmd BufWritePre <buffer> lua vim.lsp.buf.format()"
			-- end
		end,
	})
end

return M
