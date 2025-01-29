return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  opts = {
    suggestion = {
      -- enabled = not vim.g.ai_cmp,
      enabled = true,
      auto_trigger = true,
      keymap = {
        -- accept = false, -- handled by nvim-cmp / blink.cmp
        accept = "<M-Tab>",
        next = "<M-]>",
        prev = "<M-[>",
      },
    },
    -- panel = { enabled = false },
    panel = { enabled = true },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
}
