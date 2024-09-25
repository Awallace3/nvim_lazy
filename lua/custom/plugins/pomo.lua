return {
  "epwalsh/pomo.nvim",
  version = "*", -- Recommended, use latest release instead of latest commit
  lazy = true,
  cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
  dependencies = {
    -- Optional, but highly recommended if you want to use the "Default" timer
    "rcarriga/nvim-notify",
  },
  opts = {
    -- See below for full list of options 👇
  },
  config = function()
    require("pomo").setup({
      sessions = {
        m = {
          { name = "Work",        duration = "45m" },
          { name = "Short break", duration = "5m" },
        },
        writing = {
          { name = "Work",        duration = "27.5m" },
          { name = "Short break", duration = "5m" },
          { name = "Work",        duration = "27.5m" },
        },
      }
    }
    )
  end
}
