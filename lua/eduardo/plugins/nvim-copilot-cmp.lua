return {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    enabled = false,
    config = function()
        require("copilot_cmp").setup()
    end,
}
