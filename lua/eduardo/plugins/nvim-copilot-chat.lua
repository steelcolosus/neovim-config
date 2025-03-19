local diagnostics = function(source)
    local bufnr = source.bufnr
    local winnr = source.winnr
    local select_buffer = buffer(source)
    if not select_buffer then
        return nil
    end

    local cursor = vim.api.nvim_win_get_cursor(winnr)

    local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, cursor[1] - 1)

    if #line_diagnostics == 0 then
        return nil
    end

    local diagnostics = {}
    for _, diagnostic in ipairs(line_diagnostics) do
        table.insert(diagnostics, diagnostic.message)
    end

    local result = table.concat(diagnostics, ". ")
    result = result:gsub("^%s*(.-)%s*$", "%1"):gsub("\n", " ")

    local file_name = vim.api.nvim_buf_get_name(bufnr)

    local out = {
        content = file_name .. ":" .. cursor[1] .. ". " .. result,
        filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p:."),
        filetype = vim.bo[bufnr].filetype,
        start_line = cursor[1],
        end_line = cursor[1],
        bufnr = bufnr,
    }

    return out
end

local git_diff = function(source, staged, buffer)
    local select_buffer = buffer(source)
    if not select_buffer then
        return nil
    end
    local file_path = vim.api.nvim_buf_get_name(source.bufnr)
    local file_dir = vim.fn.fnamemodify(file_path, ":h")
    -- check file dir is exist, or use current dir instead
    if vim.fn.isdirectory(file_dir) == 0 then
        file_dir = vim.fn.getcwd()
    end

    -- NOTE: Fix vulnerability #417 in CopilotC-Nvim/CopilotChat.nvim
    file_dir = file_dir:gsub(".git$", "")

    local cmd_diff = "git -C "
        .. file_dir
        .. " diff --no-color --no-ext-diff"
        .. (staged and " --staged" or "")
        .. " 2>/dev/null"
    local cmd_diff_stat = "git -C "
        .. file_dir
        .. " diff --stat --no-color --no-ext-diff"
        .. (staged and " --staged" or "")
        .. " 2>/dev/null"

    local handle = io.popen(cmd_diff)
    if not handle then
        return nil
    end

    local result = handle:read("*a")
    handle:close()

    -- jugde if the diff is too large (> 30000 characters) to handle, use diff --stat to instead
    if #result > 30000 then
        handle = io.popen(cmd_diff_stat)
        if not handle then
            return nil
        end

        result = handle:read("*a")
        handle:close()
    end

    if not result or result == "" then
        return nil
    end

    return {
        content = result,
        filename = "git_diff_" .. (staged and "staged" or "unstaged"),
        filetype = "diff",
    }
end

return {
    { import = "eduardo.plugins.nvim-copilot" },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        build = "make tiktoken",
        dependencies = {
            { "github/copilot.vim" }, -- or github/copilot.vim
            { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log wrapper
            { "nvim-telescope/telescope.nvim" }, -- Use telescope for help actions
        },
        opts = {
            debug = true, -- Enable debugging
            show_help = true, -- Show help actions
            --[[ window = {
                layout = "float",
            }, ]]
            auto_follow_cursor = false, -- Don't follow the cursor after getting response
            auto_insert_mode = true,
            prompts = {
                -- Code related prompts
                Explain = "Please explain how the following code works.",
                Review = "Please review the following code and provide suggestions for improvement.",
                Tests = "Please explain how the selected code works, then generate unit tests for it.",
                Refactor = "Please refactor the following code to improve its clarity and readability.",
                FixCode = "Please fix the following code to make it work as intended.",
                FixError = "Please explain the error in the following text and provide a solution.",
                BetterNamings = "Please provide better names for the following variables and functions.",
                Documentation = "Please provide documentation for the following code.",
                SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
                SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
                -- Text related prompts
                Summarize = "Please summarize the following text.",
                Spelling = "Please correct any grammar and spelling errors in the following text.",
                Wording = "Please improve the grammar and wording of the following text.",
                Concise = "Please rewrite the following text to make it more concise.",
            },
        },
        config = function(_, opts)
            local chat = require("CopilotChat")

            local select = require("CopilotChat.select")

            local buffer = require("CopilotChat.select").buffer

            select.diagnostics = diagnostics
            select.git_diff = git_diff
            opts.model = "claude-3.7-sonnet-thought"
            --[[ opts.mappings = {
                complete = {
                    insert = "",
                },
            } ]]

            opts.selection = select.unnamed

            -- Override the git prompts message
            opts.prompts.Commit = {
                prompt = "Write commit message for the change with commitizen convention",
                selection = select.git_diff,
            }
            opts.prompts.CommitStaged = {
                prompt = "Write commit message for the change with commitizen convention",
                selection = function(source)
                    return select.git_diff(source, true, buffer)
                end,
            }

            chat.setup(opts)

            vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
                chat.ask(args.args, { selection = select.visual })
            end, { nargs = "*", range = true })

            -- Inline chat with Copilot
            vim.api.nvim_create_user_command("CopilotChatInline", function(args)
                chat.ask(args.args, {
                    selection = select.visual,
                    window = {
                        layout = "float",
                        relative = "cursor",
                        width = 1,
                        height = 0.4,
                        row = 1,
                    },
                })
            end, { nargs = "*", range = true })

            -- Restore CopilotChatBuffer
            vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
                chat.ask(args.args, { selection = select.buffer })
            end, { nargs = "*", range = true })

            -- Custom buffer for CopilotChat
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "copilot-*",
                callback = function()
                    vim.opt_local.relativenumber = true
                    vim.opt_local.number = true

                    -- Get current filetype and set it to markdown if the current filetype is copilot-chat
                    local ft = vim.bo.filetype
                    if ft == "copilot-chat" then
                        vim.bo.filetype = "markdown"
                    end
                end,
            })
        end,
        event = "VeryLazy",
        keys = {
            -- show prompts actions with telescope
            {
                "<leader>ccp",
                function()
                    require("CopilotChat").select_prompt()
                end,
                desc = "copilotchat - prompt actions",
                mode = { "n", "v" },
            },
            -- Code related commands
            { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
            { "<leader>cct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
            { "<leader>ccr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
            { "<leader>ccR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
            { "<leader>ccn", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
            -- Chat with Copilot in visual mode
            {
                "<leader>ccv",
                ":CopilotChatVisual<cr>",
                mode = "x",
                desc = "CopilotChat - Open in vertical split",
            },
            {
                "<leader>ccx",
                ":CopilotChatInline<cr>",
                mode = "x",
                desc = "CopilotChat - Inline chat",
            },
            -- Custom input for CopilotChat
            {
                "<leader>cci",
                function()
                    local input = vim.fn.input("Ask Copilot: ")
                    if input ~= "" then
                        vim.cmd("CopilotChat " .. input)
                    end
                end,
                desc = "CopilotChat - Ask input",
            },
            -- Generate commit message based on the git diff
            {
                "<leader>ccm",
                "<cmd>CopilotChatCommit<cr>",
                desc = "CopilotChat - Generate commit message for all changes",
            },
            -- Quick chat with Copilot
            {
                "<leader>ccq",
                function()
                    local input = vim.fn.input("Quick Chat: ")
                    if input ~= "" then
                        vim.cmd("CopilotChatBuffer " .. input)
                    end
                end,
                desc = "CopilotChat - Quick chat",
            },
            -- Debug
            { "<leader>ccd", "<cmd>CopilotChatDebugInfo<cr>", desc = "CopilotChat - Debug Info" },
            -- Fix the issue with diagnostic
            { "<leader>ccf", "<cmd>CopilotChatFixError<cr>", desc = "CopilotChat - Fix Diagnostic" },
            -- Clear buffer and chat history
            {
                "<leader>ccl",
                "<cmd>CopilotChatReset<cr>",
                desc = "CopilotChat - Clear buffer and chat history",
            },
            -- Toggle Copilot Chat Vsplit
            { "<leader>ccc", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle Vsplit" },
        },
    },
}
