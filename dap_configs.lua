local dap, dapui = require("dap"), require("dapui")

vim.cmd([[au FileType dap-repl lua require('dap.ext.autocompl').attach()]])

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "🔵", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "⭐️", texthl = "", linehl = "", numhl = "" })

local dapPython = require("dap-python")
dapPython.setup("/Users/dat.nguyen1/.pyenv/versions/cli/bin/python")

require("dap-go").setup()
table.insert(dap.configurations.go, {
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
	sidebar = {
		-- You can change the order of elements in the sidebar
		elements = {
			-- Provide as ID strings or tables with "id" and "size" keys
			{
				id = "scopes",
				size = 0.25, -- Can be float or integer > 1
			},
			{ id = "breakpoints", size = 0.25 },
			{ id = "stacks", size = 0.25 },
			{ id = "watches", size = 00.25 },
		},
		size = 40,
		position = "left", -- Can be "left", "right", "top", "bottom"
	},
	tray = {
		elements = { "repl" },
		size = 10,
		position = "bottom", -- Can be "left", "right", "top", "bottom"
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

-- Rust Adapter
-- ==============
dap.adapters.lldb = {
	type = "executable",
	command = "/opt/homebrew/opt/llvm/bin/lldb-vscode", -- adjust as needed, must be absolute path
	name = "lldb",
}
dap.adapters.codelldb = function(on_adapter)
	local cmd = "/Users/dat.nguyen1/.vscode/extensions/vadimcn.vscode-lldb-1.7.0/adapter/codelldb"

	-- This asks the system for a free port
	local tcp = vim.loop.new_tcp()
	tcp:bind("127.0.0.1", 0)
	local port = tcp:getsockname().port
	tcp:shutdown()
	tcp:close()

	-- Start codelldb with the port
	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)
	local opts = {
		stdio = { nil, stdout, stderr },
		args = { "--port", tostring(port) },
	}
	local handle
	local pid_or_err
	handle, pid_or_err = vim.loop.spawn(cmd, opts, function(code)
		stdout:close()
		stderr:close()
		handle:close()
		if code ~= 0 then
			print("codelldb exited with code", code)
		end
	end)
	if not handle then
		vim.notify("Error running codelldb: " .. tostring(pid_or_err), vim.log.levels.ERROR)
		stdout:close()
		stderr:close()
		return
	end
	vim.notify("codelldb started. pid=" .. pid_or_err)
	stderr:read_start(function(err, chunk)
		assert(not err, err)
		if chunk then
			vim.schedule(function()
				require("dap.repl").append(chunk)
			end)
		end
	end)
	local adapter = {
		type = "server",
		host = "127.0.0.1",
		port = port,
	}
	-- 💀
	-- Wait for codelldb to get ready and start listening before telling nvim-dap to connect
	-- If you get connect errors, try to increase 500 to a higher value, or check the stderr (Open the REPL)
	vim.defer_fn(function()
		on_adapter(adapter)
	end, 500)
end

-- configure the adapter for Rust Debugging
dap.configurations.rust = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/" .. "")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},

		-- 💀
		-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
		--
		--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
		--
		-- Otherwise you might get the following error:
		--
		--    Error on launch: Failed to attach to the target process
		--
		-- But you should be aware of the implications:
		-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
		-- runInTerminal = false,

		-- 💀
		-- If you use `runInTerminal = true` and resize the terminal window,
		-- lldb-vscode will receive a `SIGWINCH` signal which can cause problems
		-- To avoid that uncomment the following option
		-- See https://github.com/mfussenegger/nvim-dap/issues/236#issuecomment-1066306073
		-- postRunCommands = {'process handle -p true -s false -n false SIGWINCH'}
	},
}
