-- init.lua

-- Basics
vim.cmd("set expandtab")

vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

vim.wo.number = true

-- Lazy Setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

-- Plugins
local plugins = {
    {"catppuccin/nvim", name = "catppuccin", priority = 1000},
    {"windwp/nvim-autopairs", name = "autopairs", priority = 1000},
    {"nvim-tree/nvim-web-devicons"},
    {"folke/noice.nvim", dependencies = {"MunifTanjim/nui.nvim", "rcarriga/nvim-notify"}},
    {"stevearc/oil.nvim"},
    {"neovim/nvim-lspconfig"},      -- LSP config
    {"hrsh7th/nvim-cmp"},           -- completion plugin
    {"hrsh7th/cmp-nvim-lsp"},       -- LSP completion source for nvim-cmp
    {"hrsh7th/cmp-buffer"},         -- buffer completion source
    {"hrsh7th/cmp-path"},           -- file completion source
    {"saadparwaiz1/cmp_luasnip"},   -- snippet completion
    {"L3MON4D3/LuaSnip"},           -- snippet engine
    {"kyazdani42/nvim-tree.lua"},
    {"akinsho/bufferline.nvim"}
}

local opts = {}

-- Plugin Setup
require("lazy.view.config").keys.close = "<Esc>"
require("lazy").setup(plugins, opts)
require("catppuccin").setup()
require("noice").setup()
require("nvim-autopairs").setup()

require("nvim-tree").setup({
    view = {
        width = 30,
        side = "left"
    },
    hijack_directories = {
        enable = true
    },
    update_cwd = true,
    renderer = {
        highlight_opened_files = "name",
    },
    on_attach = function(bufnr)
        local api = require('nvim-tree.api')
        local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        -- keymap for opening in new buffer
        vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open: New Buffer"))
        vim.keymap.set("n", "o", api.node.open.edit, opts("Open: New Buffer"))
    end,
})

require("bufferline").setup({
    options = {
        diagnostics = "nvim_lsp",  -- LSP diagnose
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thin",
    }
})

vim.api.nvim_set_keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        require("nvim-tree.api").tree.open()
    end
})

local cmp = require'cmp'
cmp.setup({
    snippet = {
        expand = function(args)
            require'luasnip'.lsp_expand(args.body)
        end,
    },

    mapping = {
        ['<Down>'] = cmp.mapping.select_next_item(),
        ['<Up>'] = cmp.mapping.select_prev_item(),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),

    },
    sources = cmp.config.sources(
        {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        },
        {
            { name = 'buffer' },
            { name = 'path' }
        }
    )
})

local lspconfig = require'lspconfig'
lspconfig.pyright.setup{
    capabilities = require('cmp_nvim_lsp').default_capabilities()
}

local lspconfig = require'lspconfig'

lspconfig.clangd.setup{
    capabilities = require('cmp_nvim_lsp').default_capabilities()
}

-- Plugin Configs
vim.cmd.colorscheme("catppuccin")
