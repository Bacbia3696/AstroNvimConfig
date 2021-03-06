local map = vim.keymap.set

-- Remap space as leader key
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- map("", ":", ";")
map("", ";", ":")

-- lsp
map("n", "gr", "<cmd>Telescope lsp_references theme=ivy<cr>")
map("n", "gi", "<cmd>Telescope lsp_implementations<cr>")
map("n", "gt", "<cmd>Telescope lsp_type_definitions theme=dropdown<cr>")
map("n", "gd", "<cmd>Telescope lsp_definitions<cr>")
-- map("n", "ga", "<cmd>Telescope lsp_code_actions theme=cursor<cr>")
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<C-k>", vim.lsp.buf.signature_help)
map("n", "K", vim.lsp.buf.hover)
-- map("n", "go", vim.diagnostic.open_float)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "<leader>li", "<cmd>LspInfo<cr>")
map("n", "<leader>lI", "<cmd>LspInstallInfo<cr>")
map("n", "<leader>6", "<C-^>")
map("n", "<leader>5", "<cmd>Other<cr>")
map("n", "<leader>4", "<cmd>AerialToggle<cr>")
map("n", "<leader>3", "<cmd>NvimTreeToggle<cr>")
map("n", "<leader>2", "<cmd>Format<cr>")
map("n", "<leader>1", "<cmd>Telescope builtin<cr>")

-- use built-in
-- map("n", "gr", vim.lsp.buf.references)
-- map("n", "gi", vim.lsp.buf.implementation)
-- map("n", "gd", vim.lsp.buf.definition)
-- map("n", "gt", vim.lsp.buf.type_definition)
map("n", "ga", vim.lsp.buf.code_action)

-- format onsave
map({ "i", "n", "v", "s" }, "<C-s>", "<esc><cmd>Format<cr><cmd>up<CR>", { silent = true })
map("", "<leader>q", "<cmd>qa<CR>")
map("", "<C-q>", "<cmd>q<cr>")
map("i", "<C-q>", "<esc><cmd>q<cr>")

-- mapping in insert/command mode just like emacs
map("!", "<C-a>", "<Home>")
map("!", "<C-e>", "<End>")
map("!", "<C-p>", "<Up>")
map("!", "<C-n>", "<Down>")
map("!", "<C-b>", "<Left>")
map("!", "<C-f>", "<Right>")
map("!", "<M-b>", "<S-Left>")
map("!", "<M-f>", "<S-Right>")

-- SessionManager
map("", "<leader>Sl", "<cmd>SessionManager! load_last_session<cr>")
map("", "<leader>Ss", "<cmd>SessionManager! save_current_session<cr>")
map("", "<leader>Sd", "<cmd>SessionManager! delete_session<cr>")
map("", "<leader>Sf", "<cmd>SessionManager! load_session<cr>")
map("", "<leader>S.", "<cmd>SessionManager! load_current_dir_session<cr>")

-- navigate vim tab
map("", "<M-k>", "<cmd>tabn<cr>")
map("", "<M-t>", "<cmd>tabnew<cr>")
map("", "<M-j>", "<cmd>tabp<cr>")
map("", "<M-k>", "<cmd>tabn<cr>")
map("", "[t", "<cmd>tabp<cr>")
map("", "]t", "<cmd>tabn<cr>")
-- navigate window
for i = 1, 9 do
	map({ "n", "i", "t" }, "<M-" .. i .. ">", "<cmd>" .. i .. "wincmd w<cr>")
end

map("n", "<M-a>", "ggVG")
map("n", "<C-w>>", "5<C-w>>")
map("n", "<C-w><", "5<C-w><")

map("n", "*", "<cmd>keepjumps normal! mi*`i<CR>")
map("n", ",p", [["0p]])
map("n", ",P", [["0P]])

-- undo breakpoint
for _, c in ipairs({ ",", "?", ".", "!" }) do
	map("i", c, c .. "<c-g>u")
end

-- plugin mapping
map("n", "<leader><leader>", "<cmd>Telescope find_files<cr>")
map("n", "<leader>y", "<cmd>Telescope neoclip<cr>")
map("n", "<leader>da", "<cmd>Telescope diagnostics<cr>")

-- hop
map({ "n", "o", "x" }, "f", "<CMD>HopChar1<CR>")
map({ "n", "o", "x" }, "F", "<CMD>HopWord<CR>")

-- telescope

map("n", "<leader>fw", function()
	require("telescope.builtin").live_grep()
end)
-- map("n", "<leader>gt", function()
--   require("telescope.builtin").git_status()
-- end)
-- map("n", "<leader>gb", function()
--   require("telescope.builtin").git_branches()
-- end)
-- map("n", "<leader>gc", function()
--   require("telescope.builtin").git_commits()
-- end)
map("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end)
map("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end)
map("n", "<leader>fh", function()
	require("telescope.builtin").help_tags()
end)
map("n", "<leader>fm", function()
	require("telescope.builtin").marks()
end)
map("n", "<leader>fo", function()
	require("telescope.builtin").oldfiles()
end)
-- map("n", "<leader>sb", function()
--   require("telescope.builtin").git_branches()
-- end)
-- map("n", "<leader>sh", function()
--   require("telescope.builtin").help_tags()
-- end)
map("n", "<leader>sm", function()
	require("telescope.builtin").man_pages()
end)
map("n", "<leader>sn", function()
	require("telescope").extensions.notify.notify()
end)
map("n", "<leader>sr", function()
	require("telescope.builtin").registers()
end)
map("n", "<leader>sk", function()
	require("telescope.builtin").keymaps()
end)
map("n", "<leader>sc", function()
	require("telescope.builtin").commands()
end)
map("n", "<leader>ls", function()
	require("telescope.builtin").lsp_document_symbols()
end)
map("n", "<leader>lR", function()
	require("telescope.builtin").lsp_references()
end)
map("n", "<leader>lD", function()
	require("telescope.builtin").diagnostics()
end)

-- toggleterm

local _user_terminals = {}
local function toggle_term_cmd(cmd)
	if _user_terminals[cmd] == nil then
		_user_terminals[cmd] = require("toggleterm.terminal").Terminal:new({ cmd = cmd, hidden = true })
	end
	_user_terminals[cmd]:toggle()
end

map("n", "<leader>gg", function()
	toggle_term_cmd("NVIM_LISTEN_ADDRESS=" .. vim.v.servername .. " lazygit")
end)
map("n", "<leader>tn", function()
	toggle_term_cmd("node")
end)
map("n", "<leader>tu", function()
	toggle_term_cmd("ncdu")
end)
map("n", "<leader>tt", function()
	toggle_term_cmd("htop")
end)
map("n", "<leader>tp", function()
	toggle_term_cmd("python")
end)
map("n", "<leader>tl", function()
	toggle_term_cmd("NVIM_LISTEN_ADDRESS=" .. vim.v.servername .. " lazygit")
end)
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>")
map("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>")
map("n", "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>")

-- packer
map("n", "<leader>pc", "<cmd>PackerCompile<cr>")
map("n", "<leader>pi", "<cmd>PackerInstall<cr>")
map("n", "<leader>ps", "<cmd>PackerSync<cr>")
map("n", "<leader>pS", "<cmd>PackerStatus<cr>")
map("n", "<leader>pu", "<cmd>PackerUpdate<cr>")

map("t", "<C-q>", [[<C-\><C-n>]])
-- pbpaste > /tmp/file.html && htmltojsx /tmp/file.html | pbcopy
map("n", "so", [[:execute '!open %'<CR>]])
map("n", "sp", [[:execute '!echo -n %:p:h | pbcopy'<CR>]])
map("n", "sf", [[:execute '!echo -n %:p | pbcopy'<CR>]])
map("n", "sd", function()
	local file = vim.fn.expand("%:p") .. ":" .. vim.fn.line(".")
	print("!echo -n '" .. file .. "' | pbcopy")
	vim.fn.execute("!echo -n '" .. file .. "' | pbcopy")
end)
map("n", "st", [[yat :silent execute '!pbpaste > /tmp/file.html && htmltojsx /tmp/file.html | pbcopy'<CR> vatp]])

vim.keymap.set("n", "<C-y>", "3<Cmd>lua Scroll('<C-y>', 0, 1)<CR>")
vim.keymap.set("n", "<C-e>", "3<Cmd>lua Scroll('<C-e>', 0, 1)<CR>")
