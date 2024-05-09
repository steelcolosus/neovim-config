vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" } )

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) --increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) --increment

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split windwo horizontally"}) 
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- tabs management
keymap.set("n", "<leader>to",  "<cmd>tabnew<CR>", { desc = "Open new Tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current Tab" }) 
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next Tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })


