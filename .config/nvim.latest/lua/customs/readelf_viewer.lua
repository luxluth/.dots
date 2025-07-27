local ElfViewer = {}

-- Function to check if the file is an ELF binary
local function is_elf_file(filepath)
  local f = io.open(filepath, "rb")
  if not f then
    return false
  end
  local magic = f:read(4)
  f:close()
  return magic == "\x7FELF"
end

-- Function to replace the current buffer with readelf output
local function show_readelf_output(filepath)
  -- Create a new buffer for the readelf output
  local bufnr = vim.api.nvim_create_buf(true, false)

  -- Switch to the new buffer and delete the old one
  vim.api.nvim_set_current_buf(bufnr)

  -- Run readelf asynchronously and populate the buffer
  vim.fn.jobstart("readelf -a " .. vim.fn.shellescape(filepath), {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, data)
      end
    end,
  })

  vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
  vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
end

-- Auto command to trigger on ELF files
function ElfViewer.setup()
  vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
      local filepath = vim.fn.expand("%:p")
      if is_elf_file(filepath) then
        show_readelf_output(filepath)
      end
    end,
  })
end

return ElfViewer
