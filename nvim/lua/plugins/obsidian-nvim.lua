local function search_link(flags)
  local markdown_link = "\\[[^]]*](.*)"
  local wiki_link = "\\[\\[[^]]*]]"
  vim.fn.search(markdown_link .. "\\|" .. wiki_link, flags)
end

return {
  "epwalsh/obsidian.nvim",
  -- the obsidian vault in this default config  ~/obsidian-vault
  -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
  -- event = { "bufreadpre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
  event = { "BufReadPre  */workspace/notes/*.md" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            -- Opens the home page.
            ["<Leader>ww"] = {
              "<Cmd>e " .. vim.env.HOME .. "/workspace/notes/Home.md<CR>",
              desc = "Obsidian - Home",
            },
          },
          v = {
            ["<CR>"] = {
              "<Cmd>ObsidianLinkNew<CR>",
              desc = "Obsidian - Link New",
            },
          },
        },
        options = {
          opt = {
            -- Obsidian additional syntax features require 'conceallevel' to be set to 1 or 2.
            conceallevel = 2, -- required for obsidian
          },
        },
      },
    },
  },
  opts = {
    workspaces = {
      {
        name = "notes",
        path = vim.env.HOME .. "/workspace/notes",
      },
    },

    use_advanced_uri = true,
    finder = "telescope.nvim",

    templates = {
      subdir = "templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },

    -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
    -- way then set 'mappings = {}'.
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ["<CR>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
        desc = "Obsidian - Smart action",
      },
      -- Jump to next link.
      ["<Tab>"] = {
        action = function() search_link "" end,
        opts = { buffer = true, expr = false },
        desc = "Obsidian - Jump to next link",
      },
      -- Jump to next link.
      ["<S-Tab>"] = {
        action = function() search_link "b" end,
        opts = { buffer = true, expr = false },
        desc = "Obsidian - Jump to next link",
      },
    },

    note_frontmatter_func = function(note)
      -- This is equivalent to the default frontmatter function.
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and require("obsidian").util.table_length(note.metadata) > 0 then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    follow_url_func = vim.ui.open or function(url) require("astrocore").system_open(url) end,
  },
}
