-- TODO: move this to other place
local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")
if not configs.ls_emmet then
	configs.ls_emmet = {
		default_config = {
			cmd = { "ls_emmet", "--stdio" },
			filetypes = {
				"html",
				"css",
				"scss",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"haml",
				"xml",
				"xsl",
				"pug",
				"slim",
				"sass",
				"stylus",
				"less",
				"sss",
				"hbs",
				"handlebars",
			},
			root_dir = function(fname)
				return vim.loop.cwd()
			end,
			-- FIXME: this have no effect
			settings = {
				syntaxProfiles = {
					html = "xhtml",
				},
			},
		},
	}
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
lspconfig.ls_emmet.setup({ capabilities = capabilities })
