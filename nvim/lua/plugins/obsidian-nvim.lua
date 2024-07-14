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

    -- Optional, customize how note IDs are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      local datestamp = os.date("%Y-%m-%d", os.time())
      if title == nil then
        title = ""
      end
      return datestamp .. " - " .. title
    end,

    -- Optional, customize how note file names are generated given the ID, target directory, and title.
    ---@param spec { id: string, dir: obsidian.Path, title: string|? }
    ---@return string|obsidian.Path The full path to the new note.
    note_path_func = function(spec)
      -- This is equivalent to the default behavior.
      local path = spec.dir / tostring(spec.id)
      return path:with_suffix(".md")
    end,

    -- Optional, customize the frontmatter data.
    note_frontmatter_func = function(note)
      -- Add the title of the note as an alias.
      if note.title then
        note:add_alias(note.title)
      end

      local timestamp = os.date("%Y-%m-%d", os.time())
      local out = {
        id = note.id,
        aliases = note.aliases,
        tags = note.tags,
        created_at = timestamp,
        updated_at = timestamp,
      }

      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          -- Always update the last updated timestamp.
          if k ~= "updated_at" then
            out[k] = v
          end
        end
      end

      return out
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    follow_url_func = vim.ui.open or function(url) require("astrocore").system_open(url) end,
  },
}
