return {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",  -- Required for Job and HTTP requests
    },
    -- comment the following line to ensure hub will be ready at the earliest
    cmd = "MCPHub",  -- lazy load by default
    build = "npm install -g mcp-hub@latest",  -- Installs required mcp-hub npm module
    -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    config = function()
      require("mcphub").setup({
        port = 3000,
        config = os.getenv("HOME") .. "/.config/mcp-hub/mcp-servers.json",
        on_ready = function(hub)
            vim.notify(string.format("MCP Hub is ready. %s servers active", #vim.tbl_filter(function(s)
                return s.status == "connected"
            end, hub:get_state().server_state.servers or {})), vim.log.levels.INFO)
        end
    })
    end,
}
