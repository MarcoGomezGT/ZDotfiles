local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local surround_chars = "[\"'(){}%[%]]"

local function merge_tables(t1, t2)
  local result = {}
  for k, v in pairs(t1) do
    result[k] = v
  end
  for k, v in pairs(t2) do
    result[k] = v
  end
  return result
end

local function copy_diagnostics_to_clipboard()
  local diagnostics = vim.diagnostic.get(0)
  local lines = {}
  for _, diag in ipairs(diagnostics) do
    table.insert(lines, diag.message)
  end
  local text = table.concat(lines, "\n")
  vim.fn.setreg("+", text)
  print("Diagnostics copied to clipboard!")
end

local function copy_file_and_diagnostics_to_clipboard()
  local file_path = vim.fn.expand("%")
  local relative_file_path = vim.fn.fnamemodify(file_path, ":~:.")
  local file_extension = vim.fn.fnamemodify(file_path, ":e")
  local markdown_code_block_identifier = file_extension
  local extension_to_markdown = {
    ts = "typescript",
    js = "javascript",
    py = "python",
  }
  if extension_to_markdown[file_extension] then
    markdown_code_block_identifier = extension_to_markdown[file_extension]
  end
  local file_content = table.concat(vim.fn.readfile(file_path), "\n")
  local diagnostics = vim.diagnostic.get(0)
  local diagnostic_lines = {}
  for _, diag in ipairs(diagnostics) do
    local line_content = vim.fn.getline(diag.lnum + 1)
    table.insert(
      diagnostic_lines,
      string.format("\n\n>- Line %d: `%s`\n>- Diagnostic: %s\n", diag.lnum + 1, line_content, diag.message)
    )
  end
  local diagnostics_text = table.concat(diagnostic_lines, "\n\n")
  local clipboard_text = string.format(
    "File: %s\n\n```%s\n%s\n```\n\nDiagnostics:\n%s",
    relative_file_path,
    markdown_code_block_identifier,
    file_content,
    diagnostics_text
  )
  vim.fn.setreg("+", clipboard_text)
  print("File and diagnostics copied to clipboard!")
end

local function create_and_preview_diagnostics()
  copy_file_and_diagnostics_to_clipboard()
  local diagnostics_file_path = vim.fn.getcwd() .. "/diagnostics.md"
  vim.cmd("e " .. diagnostics_file_path)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
  vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
  vim.cmd("write")
  vim.cmd("MarkdownPreview")
end

keymap.set("n", "<leader>ccm", create_and_preview_diagnostics, opts)
keymap.set("n", "<leader>cca", copy_file_and_diagnostics_to_clipboard, opts)
keymap.set("n", "<leader>cc", copy_diagnostics_to_clipboard, opts)

keymap.set("n", "<leader>#", "#N", opts)

-- Move lines around
keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", opts)
keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", opts)

-- New tab
keymap.set("n", "te", "tabedit", opts)

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move around
keymap.set("n", "<leader><Left>", "<C-w>h")
keymap.set("n", "<leader><Right>", "<C-w>l")
keymap.set("n", "<leader><Up>", "<C-w>k")
keymap.set("n", "<leader><Down>", "<C-w>j")
keymap.set("n", "<A-Right>", ":BufferLineCycleNext<CR>", opts)
keymap.set("n", "<A-Left>", ":BufferLineCyclePrev<CR>", opts)
keymap.set("n", "<S-A-Right>", ":BufferLineMoveNext<CR>", opts)
keymap.set("n", "<S-A-Left>", ":BufferLineMovePrev<CR>", opts)

-- Resize
keymap.set("n", "<C-w><Left>", "<C-w><")
keymap.set("n", "<C-w><Right>", "<C-w>>")

-- Disable default macro record
keymap.set("n", "q", "<Nop>", opts)

-- Normie emulation
keymap.set("n", "<S-End>", "v$")
keymap.set("v", "<S-End>", "g_", opts)
keymap.set("i", "<S-End>", "<Esc>v$", opts)

keymap.set("n", "<S-Home>", "v0")
keymap.set("v", "<S-Home>", "0", opts)
keymap.set("i", "<S-Home>", "<Esc>v0", opts)

keymap.set("n", "<C-a>", "gg<S-v>G")

keymap.set("v", "<C-c>", '"+y', opts)

-- keymap.set("n", "<C-x>", '"+d', opts)
keymap.set("v", "<C-x>", '"+d', opts)

keymap.set("n", "<C-v>", '"+p', opts)
keymap.set("i", "<C-v>", "<C-r>+", { noremap = true })

-- moving lines up and down with Alt + keys in normal mode or insert mode
keymap.set("n", "<A-Up>", ":m .-2<CR>==", opts)
keymap.set("i", "<A-Up>", "<Esc>:m .-2<CR>==gi", opts)
keymap.set("n", "<A-Down>", ":m .+1<CR>==", opts)
keymap.set("i", "<A-Down>", "<Esc>:m .+1<CR>==gi", opts)

-- making shift + down and shift + up select lines
keymap.set("n", "<S-Down>", "v<Down>", opts)
keymap.set("v", "<S-Down>", "j", opts)
keymap.set("n", "<S-Up>", "v<Up>", opts)
keymap.set("v", "<S-Up>", "k", opts)

-- tab or shift+tab on normal mode to indent right or left the current line
keymap.set("n", "<Tab>", ">>")
keymap.set("n", "<S-Tab>", "<<")

-- on insert mode, tab or shift+tab will indent right or left the current line
-- keymap.set("i", "<Tab>", "<C-t>")
-- keymap.set("i", "<S-Tab>", "<C-d>")

-- on visual mode, tab or shift+tab will indent right or left the selected lines
keymap.set("v", "<Tab>", ">gv")
keymap.set("v", "<S-Tab>", "<gv")

-- on visual mode, Ctrl + f should search the word under the cursor in the current buffer
vim.keymap.set("n", "<C-f>", function()
  require("telescope.builtin").grep_string({
    search = vim.fn.expand("<cword>"),
    use_regex = false,
  })
end, opts)

-- on insert mode, Ctrl + f should search the word under the cursor in the current buffer
vim.keymap.set("i", "<C-f>", function()
  local word = vim.fn.expand("<cword>")
  vim.cmd("stopinsert")
  require("telescope.builtin").grep_string({
    search = word,
    use_regex = false,
  })
end, opts)

-- On normal mode, Ctrl + g searches the word under the cursor in the entire project
vim.keymap.set("n", "<C-g>", function()
  require("telescope.builtin").live_grep({
    default_text = vim.fn.expand("<cword>"),
  })
end, opts)

-- On insert mode, Ctrl + g searches the word under the cursor in the entire project
vim.keymap.set("i", "<C-g>", function()
  local word = vim.fn.expand("<cword>")
  vim.cmd("stopinsert")
  require("telescope.builtin").live_grep({
    default_text = word,
  })
end, opts)

-- Back to start
vim.keymap.set("n", "<leader>qA", function()
  vim.cmd("bufdo bwipeout")
  vim.cmd("Alpha")
end, merge_tables(opts, { desc = "Close all buffers and return to dashboard" }))
