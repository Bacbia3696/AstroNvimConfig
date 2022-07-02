-- Set options
local set = vim.opt
set.list = true
-- ↵,→,~,↷,↶,·,¬,⇨⋄,‸,⇥,➜,⟫,➪,➭,⚬,⮐
set.listchars = { tab = "➪➤", trail = "⚬", eol = "¬", nbsp = "+", extends = "→", precedes = "←" }
set.relativenumber = false
set.confirm = true
set.history = 1000 -- Number of commands to remember in a history table

-- wrap line
set.wrap = true
set.linebreak = true
set.showbreak = "↪ "
set.cpo:append({ n = true })
set.foldmethod = "indent"
set.foldlevelstart = 10
set.cmdheight = 1

set.winblend = 0
set.pumblend = 0
set.timeoutlen = 1000
set.smartindent = false
set.cindent = false
set.cursorline = false
set.showtabline = 1
set.conceallevel = 0
-- set.wildignore:append({ "api/*", "go.sum" })

vim.g["slime_target"] = "kitty"

vim.g.indent_blankline_char = "▏"

vim.api.nvim_create_user_command("Format", function()
	vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
end, {})

vim.cmd("cnoreabbrev t Telescope")
vim.cmd("cnoreabbrev n Neorg")

vim.cmd([[
" print synstack group name
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
]])

-- DiffWithSaved
vim.cmd([[
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()
" auto insert mode
autocmd TermOpen * startinsert
autocmd BufWinEnter,WinEnter term://* startinsert
com OR lua vim.lsp.buf.execute_command({command = "_typescript.organizeImports", arguments = {vim.fn.expand("%:p")}})
]])

vim.cmd([[
"https://stackoverflow.com/questions/2295410/how-to-prevent-the-cursor-from-moving-back-one-character-on-leaving-insert-mode
" autocmd InsertLeave * :normal! `^
" set virtualedit=onemore
" wrong indent yaml
autocmd FileType yaml setl indentkeys-=<:>
]])

-- vim.lsp.set_log_level(0)
