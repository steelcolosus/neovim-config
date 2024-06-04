return {
    "uga-rosa/ccc-nvim",
    url = "https://github.com/uga-rosa/ccc.nvim.git",
    config = function()
        -- Enable true colors
        vim.opt.termguicolors = true
        local ccc = require("ccc")
        local mapping = ccc.mapping

        ccc.setup({
            highlighter = {
                auto_enable = true,
                lsp = true,
            },
        })
    end,
}
