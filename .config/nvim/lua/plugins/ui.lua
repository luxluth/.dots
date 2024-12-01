return {
  "goolord/alpha-nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {

      [[ooooo   ooooo                                                                 ]],
      [[`888'   `888'                                                                 ]],
      [[ 888     888   .oooo.   ooo. .oo.  .oo.   ooo. .oo.  .oo.    .ooooo.  oooo d8b]],
      [[ 888ooooo888  `P  )88b  `888P"Y88bP"Y88b  `888P"Y88bP"Y88b  d88' `88b `888""8P]],
      [[ 888     888   .oP"888   888   888   888   888   888   888  888ooo888  888    ]],
      [[ 888     888  d8(  888   888   888   888   888   888   888  888    .o  888    ]],
      [[o888o   o888o `Y888""8o o888o o888o o888o o888o o888o o888o `Y8bod8P' d888b   ]],
    }

    _Gopts = {
      position = "center",
      hl = "Type",
    }

    local function footer()
      return "Le code est un roman que seuls les initiés comprennent"
    end

    dashboard.section.footer.val = footer()

    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)
  end,
}
