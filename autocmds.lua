-- Set autocommands
vim.cmd([[
  augroup packer_conf
    autocmd!
    autocmd bufwritepost plugins.lua source <afile> | PackerCompile
  augroup end
]])

local group = vim.api.nvim_create_augroup("utils", { clear = true })
-- disable auto add comment new line
vim.api.nvim_create_autocmd("BufEnter", { pattern = "*", command = "set formatoptions-=cro", group = group })
-- highlight yanked text
vim.api.nvim_create_autocmd(
	"TextYankPost",
	{ command = "silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=200 }", group = group }
)

-- open last leave position
vim.api.nvim_create_autocmd("BufReadPost", {
	command = [[ if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif ]],
	group = group,
})

-- colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	command = [[highlight LineNr guifg=grey
  highlight TSTag guifg=#e5c07b
  highlight TSString guifg=#61afef
  highlight TSFunction guifg=#4FD3C4
  highlight TSInclude guifg=#56b6c2
  highlight TSNamespace guifg=#c678dd
  highlight TSConditional guifg=#40d9ff
  highlight TSRepeat guifg=#40d9ff
  highlight TSConstBuiltin guifg=#ffbba6
  highlight TSComment guifg=#73777B gui=italic
  highlight TSFuncMacro guifg=#4E944F gui=bold
  highlight TSKeywordOperator guifg=#4E944F gui=bold
  highlight TSException guifg=#4E944F gui=bold
  highlight TSType guifg=#FF8C8C
  highlight TSTypeBuiltin guifg=#FFE3A9

  highlight VertSplit guifg=#56b6c2 guibg=NONE
  highlight TabLineSel guifg=#40d9ff guibg=NONE
  highlight TabLine guifg=#ffffff guibg=NONE
  highlight TabLineFill guibg=NONE
  highlight GitSignsCurrentLineBlame guifg=#2B8C96 gui=italic
  highlight Folded guibg=NONE gui=underline,italic

  highlight TelescopePreviewLine guibg=#3e4452
  highlight TelescopeSelection guifg=#56b6c2
  ]],
})

-- sql
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sql", "rust" },
	command = [[set ts=4 | set sw=4]],
})

-- vim.api.nvim_create_autocmd("BufRead", {
-- 	pattern = { "tsconfig.json" },
-- 	command = "set ft=jsonc",
-- })

-- for typescript definition files
vim.api.nvim_create_autocmd("BufRead", {
	pattern = { "lib*.d.ts" },
	command = "ed ++ff=dos %",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "neorg" },
	command = "set concealcursor=nc | set conceallevel=2",
})
