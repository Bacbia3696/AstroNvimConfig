---@diagnostic disable: missing-parameter
local dap, dapui = require("dap"), require("dapui")

vim.cmd([[au FileType dap-repl lua require('dap.ext.autocompl').attach()]])

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
	vim.cmd([[NvimTreeClose]])
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "🟣", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "🔵", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "👉", texthl = "", linehl = "", numhl = "" })

local dapPython = require("dap-python")
dapPython.setup("/Users/dat.nguyen1/.pyenv/versions/cli/bin/python")

require("dap-go").setup()
table.insert(dap.configurations.go, 1, {
	initialize_timeout_sec = 20,
	type = "go",
	request = "launch",
	name = "Gato debug",
	program = "./cmd",
	args = { "server" },
})

-- Add some basic support for launch.json file like vscode
require("dap.ext.vscode").load_launchjs()

require("nvim-dap-virtual-text").setup({
	enabled = true, -- enable this plugin (the default)
	enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
	highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
	highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
	show_stop_reason = true, -- show stop reason when stopped for exceptions
	commented = false, -- prefix virtual text with comment string
	-- experimental features:
	virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
	all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
	virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
	virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
	-- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
})

dapui.setup({
	icons = { expanded = "▾", collapsed = "▸" },
	mappings = {
		-- Use a table to apply multiple mappings
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	-- Expand lines larger than the window
	-- Requires >= 0.7
	expand_lines = vim.fn.has("nvim-0.7"),
	-- Layouts define sections of the screen to place windows.
	-- The position can be "left", "right", "top" or "bottom".
	-- The size specifies the height/width depending on position.
	-- Elements are the elements shown in the layout (in order).
	-- Layouts are opened in order so that earlier layouts take priority in window sizing.
	layouts = {
		{
			elements = {
				-- Elements can be strings or table with id and size keys.
				{ id = "scopes", size = 0.25 },
				"breakpoints",
				"stacks",
				"watches",
			},
			size = 40,
			position = "left",
		},
		{
			elements = {
				"repl",
				"console",
			},
			size = 10,
			position = "bottom",
		},
	},
	floating = {
		max_height = nil, -- These can be integers or a float between 0 and 1.
		max_width = nil, -- Floats will be treated as percentage of your screen.
		border = "single", -- Border style. Can be "single", "double" or "rounded"
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	windows = { indent = 1 },
	render = {
		max_type_length = nil, -- Can be integer or nil.
	}
})

vim.cmd([[
nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>

" dapui
nnoremap <leader>dd :lua require('dapui').toggle()<CR>
]])

dap.adapters.rust = {
	type = "executable",
	command = "/opt/homebrew/opt/llvm/bin/lldb-vscode", -- adjust as needed, must be absolute path
	name = "lldb",
}

-- configure the adapter for Rust Debugging
dap.configurations.rust = dap.configurations.rust or {}
table.insert(dap.configurations.rust, 1, {
	name = "Launch",
	type = "rust",
	request = "launch",
	program = function()
		function Split(s, delimiter)
			local result = {}
			for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
				table.insert(result, match)
			end
			return result
		end

		local cwd = vim.fn.getcwd()
		local p = Split(cwd, "/")
		local pkg = p[#p]
		-- return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/" .. pkg)
		return cwd .. "/target/debug/" .. pkg
	end,
	cwd = "${workspaceFolder}",
	stopOnEntry = false,
	args = { 3, 4, 5 },
})



-- Return the path to Python executable.
---@return string
local function get_python_path()
	-- Use activated virtual environment.
	if vim.env.VIRTUAL_ENV then
		return vim.env.VIRTUAL_ENV .. '/bin/python'
	end
	-- Fallback to global pyenv Python.
	return vim.fn.exepath 'python'
end

-- Enable debugger logging if Neovim is opened in debug mode. To open Neovim
-- in debug mode, use the environment variable `DEBUG` like: `$ DEBUG=1 nvim`.
---@return boolean?
local function log_to_file()
	if vim.env.DEBUG then
		-- https://github.com/microsoft/debugpy/wiki/Enable-debugger-logs
		vim.env.DEBUGPY_LOG_DIR = vim.fn.stdpath 'cache' .. '/debugpy'
		return true
	end
end

-- dap python
require('dap-python').setup('~/.pyenv/versions/3.10.0/envs/debugpy/bin/python')
dap.configurations.python = {
	{
		name = 'Launch: file',
		type = 'python',
		request = 'launch',
		program = '${file}',
		console = 'internalConsole',
		justMyCode = false,
		pythonPath = get_python_path,
		logToFile = log_to_file,
	},
	{
		name = 'Launch: file with arguments',
		type = 'python',
		request = 'launch',
		program = '${file}',
		args = function()
			local args = vim.fn.input 'Arguments: '
			return vim.split(args, ' +', { trimempty = true })
		end,
		console = 'internalConsole',
		justMyCode = false,
		pythonPath = get_python_path,
		logToFile = log_to_file,
	},
	{
		name = 'Launch: module',
		type = 'python',
		request = 'launch',
		module = '${relativeFileDirname}',
		cwd = '${workspaceFolder}',
		console = 'internalConsole',
		justMyCode = false,
		pythonPath = get_python_path,
		logToFile = log_to_file,
	},
	{
		name = 'Launch: module with arguments',
		type = 'python',
		request = 'launch',
		module = '${relativeFileDirname}',
		cwd = '${workspaceFolder}',
		args = function()
			local args = vim.fn.input 'Arguments: '
			return vim.split(args, ' +', { trimempty = true })
		end,
		console = 'internalConsole',
		justMyCode = false,
		pythonPath = get_python_path,
		logToFile = log_to_file,
	},
	{
		type = 'python',
		request = 'attach',
		name = 'Attach: remote',
		console = 'internalConsole',
		justMyCode = false,
		pythonPath = get_python_path,
		logToFile = log_to_file,
		host = function()
			local value = vim.fn.input 'Host [127.0.0.1]: '
			if value ~= '' then
				return value
			end
			return '127.0.0.1'
		end,
		port = function()
			return tonumber(vim.fn.input 'Port [5678]: ') or 5678
		end,
	},
}

-- TODO: add dap for typescript
dap.adapters.vscode_js = {
	type = "executable",
	command = "node",
	args = {
		vim.fn.stdpath("data") .. "/vscode-js-debug/out/src/vsDebugServer.js"
	},
}

--dap.configurations.javascript = {
--	{
--		type = "vscode_js",
--		request = "launch",
--		program = "${workspaceFolder}/${file}",
--		cwd = vim.fn.getcwd(),
--		sourceMaps = true,
--		protocol = "inspector",
--		console = "integratedTerminal",
--		skipFiles = { "**/node_modules/**", "<node_internals>/**" },
--		restart = true,
--	},
--}


dap.adapters.node2 = function(cb, config)
	if config.preLaunchTask then vim.fn.system(config.preLaunchTask) end
	local adapter = {
		type = 'executable',
		command = 'node',
		args = {
			vim.fn.stdpath("data") .. '/vscode-node-debug2/out/src/nodeDebug.js'
		},
	}
	cb(adapter)
end

dap.configurations.javascript = {
	{
		name = "Launch",
		type = "node2",
		request = "launch",
		program = "${file}",
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = "inspector",
		console = "integratedTerminal",
	},
	{
		-- For this to work you need to make sure the node process is started with the `--inspect` flag.
		name = "Attach to process",
		type = "node2",
		request = "attach",
		processId = require "dap.utils".pick_process,
	},
}

dap.configurations.typescript = { -- works for node-bifrost project
	{
		name = "Launch",
		type = "node2",
		request = "launch",
		program = "${workspaceFolder}/packages/bifrost-server/dist/index.js",
		preLaunchTask = "yarn build",
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = "inspector",
		console = "integratedTerminal",
	},
	{
		-- For this to work you need to make sure the node process is started with the `--inspect` flag.
		name = "Attach to process",
		type = "node2",
		request = "attach",
		processId = require "dap.utils".pick_process,
	},
}
