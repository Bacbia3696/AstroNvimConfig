local config = {

	-- Set colorscheme
	colorscheme = "default_theme",

	options = {
		opt = {
			relativenumber = true, -- sets vim.opt.relativenumber
		},
		g = {
			loaded_matchit = false, -- disable matchit
		},
	},

	-- Default theme configuration
	default_theme = {
		diagnostics_style = { italic = true },
		-- Modify the color table
		colors = require("user.colors"),
		-- Modify the highlight groups
		highlights = function(highlights)
			local C = require("default_theme.colors")

			highlights.NonText = { fg = C.grey_2, bg = C.none }
			highlights.TabLineFill = { bg = C.none }
			highlights.TabLineSel = { fg = C.cyan }

			highlights.IndentBlanklineContextStart = { sp = C.blue_1, style = "underline" }
			highlights.IndentBlanklineContextChar = { fg = C.blue_1, style = "nocombine" }

			-- highlights.NeoTreeNormal = { bg = C.none }
			-- highlights.NeoTreeNormalNC = { bg = C.none }
			highlights.NvimTreeNormal = { bg = C.none }
			highlights.NvimTreeNormalNC = { bg = C.none }
			highlights.NvimTreeSpecialFile = { fg = C.yellow, style = "bold,underline" }

			highlights.WinSeparator = { bg = C.none }
			highlights.CursorLineNr = { fg = C.gold, bg = C.none }
			highlights.LineNr = { fg = C.grey, bg = C.none }
			highlights.CursorColumn = { fg = C.gold, bg = C.purple_1 }
			highlights.MatchParen = { style = "bold,italic,underline" }

			highlights.LspReferenceText = { fg = C.none, bg = C.grey_7 }
			highlights.LspReferenceRead = { fg = C.none, bg = C.grey_7 }
			highlights.LspReferenceWrite = { fg = C.none, bg = C.grey_7 }

			highlights.Visual = { fg = C.none, bg = C.grey_1 }
			highlights.VisualNOS = { fg = C.grey_1, bg = C.none }

			highlights.TSStrong = { fg = C.fg, style = "bold" }
			highlights.TSEmphasis = { fg = C.fg, style = "italic" }
			highlights.TSUnderline = { fg = C.blue_2, style = "underline" }
			highlights.TSTitle = { fg = C.orange, style = "bold,italic" }
			highlights.TSPunctDelimiter = { fg = C.gold }
			highlights.TSPunctSpecial = { fg = C.purple }
			highlights.TSPunctBracket = { fg = C.blue }

			highlights.GitSignsCurrentLineBlame = { fg = C.cyan, style = "italic" }

			highlights.NeorgLinkText = { fg = C.blue, style = "underline,italic" }
			highlights.VertSplit = { fg = C.white }
			return highlights
		end,
	},

	-- Disable default plugins
	enabled = {
		-- lualine = true,
		gitsigns = true,
		colorizer = true,
		comment = true,
		indent_blankline = true,
		ts_rainbow = true,
		ts_autotag = true,
		toggle_term = true,
		neo_tree = false,
		bufferline = false,
		dashboard = false,
		which_key = false,
	},

	-- Configure plugins
	plugins = require("user.plugins"),

	-- Add paths for including more VS Code style snippets in luasnip
	luasnip = {
		vscode_snippet_paths = {},
	},

	-- Extend LSP configuration
	lsp = {
		-- add to the server on_attach function
		---@diagnostic disable-next-line: unused-local
		on_attach = function(client, bufnr)
			if client.name == "gopls" then
				client.server_capabilities.documentFormattingProvider = false
			end

			if client.name == "cssmodules_ls" then
				client.server_capabilities.definitionProvider = false
			end
			if client.name == "sqls" then
				client.server_capabilities.documentFormattingProvider = false
			end
		end,

		-- override the lsp installer server-registration function
		server_registration = function(server, opts)
			-- Special code for rust.tools.nvim!
			if server == "rust_analyzer" then
				-- add custom config
				opts.settings["rust-analyzer"].cargo.allFeatures = false
				opts.settings["rust-analyzer"].proMacro = {
					enable = true,
				}
				opts.standalone = false

				require("rust-tools").setup({
					tools = {
						autoSetHints = false,
						hover_actions = {
							auto_focus = true,
						},
					},
					server = opts,
				})
			else
				require("lspconfig")[server].setup(opts)
			end
		end,

		-- Add overrides for LSP server settings, the keys are the name of the server
		["server-settings"] = {
			["tsserver"] = {
				init_options = {
					preferences = {
						importModuleSpecifierPreference = "non-relative",
					},
				},
			},
			-- ["cssmodules_ls"] = {
			--   init_options = {
			--     camelCase = true,
			--   },
			--   filetypes = { "typescriptreact", "javascriptreact", "scss", "css", "sass", "javascript" },
			-- }
		},
	},

	-- Diagnostics configuration (for vim.diagnostics.config({}))
	diagnostics = {
		virtual_text = true,
		underline = true,
	},

	-- This function is run last
	-- good place to configure mappings and vim options
	polish = function()
		require("user.opt")
		require("user.mappings")
		require("user.autocmds")
		require("user.dap_configs")
		require("user.lsp_configs")
		require("plenary.filetype").add_file("plenary_filetype")
	end,
}

return config
