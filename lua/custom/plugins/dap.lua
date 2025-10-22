local using_psi4 = false
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    'mfussenegger/nvim-dap-python',
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dap.adapters.cppdbg = {
      id = 'cppdbg',
      type = 'executable',
      command = vim.fn.stdpath('data') .. '/mason/bin/OpenDebugAD7',
      options = {
        detached = false
      }
    }
    dap.configurations.cpp = {
      {
        name = "Launch with GDB",
        type = "cppdbg",
        request = "launch",
        program = function()
          -- get input if psi4 or not. Default psi4
          local psi4 = vim.fn.input("Use psi4? (y/n): ", "y", "customlist,psi4")
          using_psi4 = psi4:lower() == 'y'
          if using_psi4 then
            conda_prefix = os.getenv("CONDA_PREFIX")
            return conda_prefix .. "/bin/python3"
          else
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end
        end,
        args = function()
          print("using_psi4: " .. tostring(using_psi4))
          if using_psi4 then
            return {
              "/home/awallace43/gits/psi4/build_saptdft_ein/stage/bin/psi4",
              "/home/awallace43/gits/psi4/tests/pytests/test_saptdft.py"
            }
          else
            return {}
          end
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        setupCommands = {
          {
            description = "Enable pretty-printing for gdb",
            text = "-enable-pretty-printing",
            ignoreFailures = false
          },
        },
      },
    }

    require("dap-python").setup("uv")

    dap.configurations.python = {
      {
        type = 'python';
        request = 'launch';
        name = "Launch file";
        program = "${file}";
        -- pythonPath = function()
        --   return '/usr/bin/python'
        -- end;
      },
    }

    dapui.setup()

    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp

    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    -- dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    -- dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    vim.keymap.set("n", "<F5>", dap.continue)
    vim.keymap.set("n", "<F10>", dap.step_over)
    vim.keymap.set("n", "<F11>", dap.step_into)
    vim.keymap.set("n", "<F12>", dap.step_out)
    vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint)
    vim.keymap.set("n", "<Leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end)
    vim.keymap.set("n", "<Leader>dr", dap.repl.open)

    -- Key to terminate the session
    vim.keymap.set("n", "<F6>", function()
      -- Gracefully terminate the session
      dap.terminate()
      -- Optionally disconnect if terminate isn't enough
      dap.disconnect()
      -- Close dapui windows and REPL
      dapui.close()
      dap.repl.close()
    end, { desc = "Terminate DAP session and clean up" })

    -- Set the breakpoint appearance
    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#5b70da', bg = '#31353f' })
    vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bg = '#31353f' })
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379', bg = '#31353f' })
    vim.fn.sign_define('DapBreakpoint',
      { text = '●', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
    vim.fn.sign_define('DapBreakpointCondition',
      { text = '●', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
    vim.fn.sign_define('DapBreakpointRejected',
      { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
    vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = 'DapLogPoint', numhl = 'DapLogPoint' })
    vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })
  end,
}
