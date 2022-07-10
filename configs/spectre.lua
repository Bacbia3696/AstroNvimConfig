local M = {}

function M.config()
	local status_ok, pkg = pcall(require, "spectre")
	if not status_ok then
		return
	end
	pkg.setup()
	vim.cmd([[
    nnoremap <leader>ss <cmd>lua require('spectre').open()<CR>
    vnoremap <leader>s <cmd>lua require('spectre').open_visual()<CR>
    "search current word
    nnoremap <leader>sw <cmd>lua require('spectre').open_visual({select_word=true})<CR>
    "  search in current file
    nnoremap <leader>sp viw:lua require('spectre').open_file_search()<cr>
]])
end

return M
