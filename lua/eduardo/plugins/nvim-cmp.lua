return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        {
            "L3MON4D3/LuaSnip",
            version = "v3.*",
            build = "make install_jsregexp",
        },
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind.nvim",
    },

    config = function()
        local cmp = require("cmp")

        local luasnip = require("luasnip")

        local lspkind = require("lspkind")

        lspkind.init({
            symbol_map = {
                Copilot = "",
            },
        })

        -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
        require("luasnip.loaders.from_vscode").lazy_load()

        --[[ cmp.event:on("menu_opened", function()
            vim.b.copilot_suggestion_hidden = true
        end)

        cmp.event:on("menu_closed", function()
            vim.b.copilot_suggestion_hidden = false
        end) ]]

        cmp.setup({
            completion = {
                completeopt = "menu,menuone,preview,noselect",
            },
            snippet = { -- configure how nvim-cmp interacts with snippet engine
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
                ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
                ["<C-b>"] = cmp.mapping.scroll_docs(-3),
                ["<C-f>"] = cmp.mapping.scroll_docs(5),
                ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
                ["<C-e>"] = cmp.mapping.abort(), -- close completion window
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
            }),
            -- sources for autocompletion
            sources = cmp.config.sources({
                { name = "copilot", group_index = 1, priority = 100 }, -- copilot
                { name = "nvim_lsp" }, -- lsp
                { name = "luasnip" }, -- snippets
                { name = "buffer" }, -- text within current buffer
                { name = "path" }, -- file system paths
                { name = "render-markdown" },
            }),
            -- configure lspkind for vs-code like pictograms in completion menu
            formatting = {
                format = lspkind.cmp_format({
                    maxwidth = 51,
                    ellipsis_char = "...",
                    mode = "symbol",
                    symbol_map = { Copilot = "" },
                }),
            },
        })
    end,
}
