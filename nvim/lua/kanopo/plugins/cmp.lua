local check_backspace = function()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end


local M = {}
-- write a function to sum tree numbers
M = {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-path",
    "zbirenbaum/copilot.lua",
    "zbirenbaum/copilot-cmp",
    "windwp/nvim-autopairs",
    "onsails/lspkind-nvim",

  },
  config = function()
    -- nvim-cmp setup
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    local lspkind = require('lspkind')
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    require("luasnip/loaders/from_vscode").lazy_load()
    require("copilot_cmp").setup({
      suggestion = {
        enabled = false,
      },
      panel = {
        enabled = false
      },
    })

    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())


    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      formatting = {
        fields = {
          "abbr",
          "kind",
          "menu",
        },
        format = lspkind.cmp_format({
          mode = "symbol",
          maxwidth = 25,
          ellipsis_char = "...",
          before = function(entry, item)
            local menu_icon = {
              nvim_lsp = "LSP",
              luasnip = "SNIP",
              buffer = "BUFF",
              path = "PATH",
              copilot = "COP",
            }
            item.menu = menu_icon[entry.source.name]
            return item
          end,
        })
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'copilot' },
      },
      mapping = {
        -- used to bring up the completion
        ["<C-Space>"] = cmp.mapping.complete(),
        -- moving with tab and shift tab
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expandable() then
            luasnip.expand()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif check_backspace() then
            fallback()
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
        -- exit suggestions
        ["<C-c>"] = cmp.mapping({
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        }),
        -- The ENTER key select the cmp suggestion
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        }),
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    }
  end,
}

return M