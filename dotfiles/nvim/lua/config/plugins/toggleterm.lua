return {
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                -- Your base config here
            })

            -- Create a terminal that will be shared between floating and vertical modes
            local shared_term = require("toggleterm.terminal").Terminal:new({
                id = 1,
                direction = "float", -- default direction
            })

            -- Create a terminal specifically for tab mode
            local tab_term = require("toggleterm.terminal").Terminal:new({
                id = 2,
                direction = "tab",
            })

            -- Command for floating terminal
            vim.api.nvim_create_user_command("Ft", function()
                shared_term:toggle(nil, "float")
            end, {})

            -- Command for vertical terminal
            vim.api.nvim_create_user_command("Vt", function()
                shared_term:toggle(80, "vertical")
            end, {})

            -- Command for tab terminal
            vim.api.nvim_create_user_command("Tt", function()
                tab_term:toggle()
            end, {})
        end,
    },
}

