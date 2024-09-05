return {
  "vhyrro/luarocks.nvim",
  priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
  -- need to execute :Lazy build image.nvim to install the rocks for magick
  opts = {
    rocks = { "magick" },
  },
}
