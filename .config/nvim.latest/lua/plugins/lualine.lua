-- local M = require("lualine.component"):extend()
--
-- M.init = function(self, options)
--   M.super.init(self, options)
--   M.autocmd()
-- end
--
-- M.macro_recording = function()
--   local recording_register = vim.fn.reg_recording()
--
--   if recording_register == "" then
--     return ""
--   else
--     return "Recording @" .. recording_register
--   end
-- end
--
-- M.autocmd = function()
--   vim.api.nvim_create_autocmd("RecordingEnter", { callback = M.refresh })
--   vim.api.nvim_create_autocmd("RecordingLeave", {
--     callback = function()
--       local timer = vim.loop.new_timer()
--       timer:start(50, 0, vim.schedule_wrap(M.refresh))
--     end,
--   })
-- end
--
-- M.refresh = function()
--   require("lualine").refresh({
--     place = { "statusline" },
--   })
-- end
--
-- M.update_status = function(self)
--   return self.macro_recording()
-- end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local colors = {}
    local scheme =
      vim.system({ "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" }, { text = true }):wait().stdout
    if scheme ~= nil and scheme:sub(0, scheme:len() - 1) ~= "'prefer-dark'" then
      -- dawnfox
      colors = {
        blue = "#286983",
        green = "#618774",
        violet = "#d685af",
        yellow = "#eea846",
        red = "#b4637a",
        cream = "#4c4769",
        black = "#ebe5df",
        grey = "#ebe0df",
        dark = "#faf4ed",
      }
    else
      -- gruv material
      colors = {
        blue = "#83a598",
        green = "#8ec07c",
        violet = "#d3869b",
        yellow = "#d8a657",
        red = "#FF4A4A",
        cream = "#fff4d2",
        black = "#1d1d1d",
        grey = "#393939",
        dark = "#292929",
      }
    end

    local theme = {
      normal = {
        a = { bg = colors.dark, fg = colors.cream, gui = "bold" },
        b = { bg = colors.grey, fg = colors.cream, gui = "bold" },
        c = { bg = colors.blue, fg = colors.black, gui = "bold" },
      },
      insert = {
        a = { bg = colors.blue, fg = colors.black, gui = "bold" },
        c = { bg = colors.violet, fg = colors.black, gui = "bold" },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.black, gui = "bold" },
        c = { bg = colors.dark, fg = colors.cream, gui = "bold" },
      },
      command = {
        a = { bg = colors.green, fg = colors.black, gui = "bold" },
        c = { bg = colors.black, fg = colors.cream, gui = "bold" },
      },
      replace = {
        a = { bg = colors.blue, fg = colors.black, gui = "bold" },
        c = { bg = colors.violet, fg = colors.black, gui = "bold" },
      },
      inactive = {
        a = { bg = colors.green, fg = colors.black, gui = "bold" },
        c = { bg = colors.black, fg = colors.cream, gui = "bold" },
      },
    }

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = theme,
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = {
          "mode",
        },
        lualine_b = {
          "branch",
          "diff",
          "diagnostics",
          {
            "buffers",
            buffers_color = {
              active = { bg = colors.yellow, fg = colors.black, gui = "bold" },
              inactive = { bg = colors.grey, fg = colors.cream, gui = "italic" },
            },
            symbols = {
              modified = " ●",
              alternate_file = "",
              directory = "",
            },
            mode = 2,
          },
        },
        lualine_c = {
          {
            "filename",
            file_status = true,
            path = 3,
            shorting_target = 0,
          },
        },
        lualine_x = {},
        lualine_y = {
          "searchcount",
          "selectioncount",
          "encoding",
          "filetype",
        },
        lualine_z = {
          "progress",
          "location",
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    })
  end,
}
