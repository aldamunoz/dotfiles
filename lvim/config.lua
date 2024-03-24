-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
vim.opt.shiftwidth = 2        -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4           -- insert 4 spaces for a tab
vim.opt.relativenumber = true -- relative line numbers


lvim.builtin.which_key.mappings["t"] = {
  name = "Diagnostics",
  t = { "<cmd>TroubleToggle<cr>", "trouble" },
  w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
  d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
  q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
  l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
  r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}
-- general
lvim.log.level = "info"
lvim.format_on_save = {
	enabled = true,
	pattern = { "*.lua", "*.py", "*.rb", "*.erb" },
	timeout = 1000,
}
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["t"] = {
	name = "Diagnostics",
	t = { "<cmd>TroubleToggle<cr>", "trouble" },
	w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
	d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
	q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
	l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
	r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}
-- -- Change theme settings
lvim.colorscheme = "onedark"
lvim.builtin.terminal.open_mapping = "<c-t>"
lvim.builtin.terminal.active = true
lvim.builtin.terminal.direction = "horizontal"


-- -- linters and formatters <https://www.lunarvim.org/docs/languages#lintingformatting>
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{ command = "black", filetypes = { "python" } },
	{ command = "djlint", filetypes = { "django", "jinja.html", "htmldjango" }, args = { "--reformat", "-" } },
	{ command = "stylua" },
	-- { command = "erb-format", filetypes = { "eruby" }, args = { "--stdin" } },
	{
		command = "prettier",
		extra_args = { "--print-width", "100" },
		filetypes = {
			"javascript",
			"typescript",
			"css",
			"scss",
			"html",
			"json",
			"yaml",
			"markdown",
			"graphql",
			"md",
			"txt",
		},
	},
})

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	{ command = "flake8", filetypes = { "python" } },
	{ command = "djlint", filetypes = { "django", "jinja.html", "htmldjango" }, args = { "--quiet", "-" } },
	{ command = "erb_lint", filetypes = { "eruby" }, args = { "--format", "json", "--stdin", "$FILENAME" } },
	{
		command = "shellcheck",
		args = { "--severity", "warning" },
	},
})
local helpers = require("null-ls.helpers")
local FORMATTING = require("null-ls.methods").internal.FORMATTING
require("null-ls").register({
	--your custom sources go here
	helpers.make_builtin({
		name = "htmlbeautifier",
		meta = {
			url = "https://github.com/threedaymonk/htmlbeautifier",
			description = "A normaliser/beautifier for HTML that also understands embedded Ruby. Ideal for tidying up Rails templates.",
		},
		method = FORMATTING,
		filetypes = { "eruby" },
		generator_opts = {
			command = "htmlbeautifier",
			args = {}, -- put any required arguments in this table
			to_stdin = true, -- instructs the command to ingest the file from STDIN (i.e. run the currently open buffer through the linter/formatter)
		},
		factory = helpers.formatter_factory,
	}),
})



lvim.plugins = {
  {
		"rmagatti/goto-preview",
		config = function()
			require("goto-preview").setup({
				width = 120, -- Width of the floating window
				height = 25, -- Height of the floating window
				default_mappings = true, -- Bind default mappings
				debug = false, -- Print debug information
				opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
				post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
				-- You can use "default_mappings = true" setup option
				-- Or explicitly set keybindings
				-- vim.cmd("nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>")
				-- vim.cmd("nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>")
				-- vim.cmd("nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>")
			})
		end,
	},
  {
    'wfxr/minimap.vim',
    build = "cargo install --locked code-minimap",
    -- cmd = {"Minimap", "MinimapClose", "MinimapToggle", "MinimapRefresh", "MinimapUpdateHighlight"},
    config = function()
      vim.cmd("let g:minimap_width = 10")
      vim.cmd("let g:minimap_auto_start = 1")
      vim.cmd("let g:minimap_auto_start_win_enter = 1")
    end,
  },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd "highlight default link gitblame SpecialComment"
      require("gitblame").setup { enabled = false }
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require('neoscroll').setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
          '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        hide_cursor = true,          -- Hide cursor while scrolling
        stop_eof = true,             -- Stop at <EOF> when scrolling downwards
        use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
        respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil,       -- Default easing function
        pre_hook = nil,              -- Function to run before the scrolling animation starts
        post_hook = nil,             -- Function to run after the scrolling animation ends
      })
    end
  },
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("todo-comments").setup()
    end,
  },
  {
		"tpope/vim-surround",

		-- make sure to change the value of `timeoutlen` if it's not triggering correctly, see https://github.com/tpope/vim-surround/issues/117
		-- setup = function()
		--  vim.o.timeoutlen = 500
		-- end
	},
	{ "mrjones2014/nvim-ts-rainbow" },
  {
    "itchyny/vim-cursorword",
    event = { "BufEnter", "BufNewFile" },
    config = function()
      vim.api.nvim_command("augroup user_plugin_cursorword")
      vim.api.nvim_command("autocmd!")
      vim.api.nvim_command("autocmd FileType NvimTree,lspsagafinder,dashboard,vista let b:cursorword = 0")
      vim.api.nvim_command("autocmd WinEnter * if &diff || &pvw | let b:cursorword = 0 | endif")
      vim.api.nvim_command("autocmd InsertEnter * let b:cursorword = 0")
      vim.api.nvim_command("autocmd InsertLeave * let b:cursorword = 1")
      vim.api.nvim_command("augroup END")
    end
  },
  {
    "navarasu/onedark.nvim"
  },
  {
    "Mofiqul/vscode.nvim"
  },
  {
		"Exafunction/codeium.vim",
		config = function()
			-- Change '<C-g>' here to any keycode you like.
			vim.keymap.set("i", "<C-g>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true })
			vim.keymap.set("i", "<c-;>", function()
				return vim.fn["codeium#CycleCompletions"](1)
			end, { expr = true })
			vim.keymap.set("i", "<c-,>", function()
				return vim.fn["codeium#CycleCompletions"](-1)
			end, { expr = true })
			vim.keymap.set("i", "<c-x>", function()
				return vim.fn["codeium#Clear"]()
			end, { expr = true })
		end,
	},
}
