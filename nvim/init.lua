-- =============================================================================
-- BOOTSTRAP: mini.nvim (needed for mini.misc safely() utility)
-- =============================================================================
vim.pack.add({ "https://github.com/echasnovski/mini.nvim" })

-- Setup mini.misc (exports put, put_text, stat_summary, bench_time globally)
require("mini.misc").setup({ make_global = { "put", "put_text", "stat_summary", "bench_time" } })

-- Create lazy loading helpers using mini.misc.safely (as per blog post)
local misc = require("mini.misc")
local later = function(f)
	misc.safely("later", f)
end

-- =============================================================================
-- PACKCHANGED HOOKS (must be defined before first vim.pack.add that needs them)
-- =============================================================================

-- Treesitter update hook
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================
local H = {}

H.keys = {
	["cr"] = vim.api.nvim_replace_termcodes("<CR>", true, true, true),
	["ctrl-y"] = vim.api.nvim_replace_termcodes("<C-y>", true, true, true),
	["ctrl-y_cr"] = vim.api.nvim_replace_termcodes("<C-y><CR>", true, true, true),
}

Config = {
	path_package = vim.fn.stdpath("data") .. "/site/",
}

Config.cr_action = function()
	if vim.fn.pumvisible() ~= 0 then
		local item_selected = vim.fn.complete_info()["selected"] ~= -1
		return item_selected and H.keys["ctrl-y"] or H.keys["ctrl-y_cr"]
	else
		return require("mini.pairs").cr()
	end
end

local nmap_leader = function(suffix, rhs, desc, opts)
	opts = opts or {}
	opts.desc = desc
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, opts)
end

local map = function(suffix, rhs, desc, opts)
	opts = opts or {}
	opts.desc = desc
	vim.keymap.set("n", suffix, rhs, opts)
end

local function confirm_and_delete_buffer()
	local confirm = vim.fn.confirm("Delete buffer and file?", "&Yes\n&No", 2)
	if confirm == 1 then
		os.remove(vim.fn.expand("%"))
		vim.api.nvim_buf_delete(0, { force = true })
	end
end

-- =============================================================================
-- IMMEDIATE LOAD: Core plugins and settings
-- =============================================================================

-- Add immediate plugins
vim.pack.add({
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/github/copilot.vim",
})

-- General settings
vim.filetype.add({
	pattern = {
		[".*%.component%.html"] = "htmlangular",
	},
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.g.copilot_no_tab_map = true

-- Colorscheme
vim.cmd("colorscheme kanagawa-dragon")

-- Mini.nvim immediate setups
require("mini.notify").setup()
vim.notify = require("mini.notify").make_notify()

require("mini.sessions").setup()

require("mini.statusline").setup()

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

-- NvimTree (immediate load for project opening)
vim.pack.add({
	"https://github.com/nvim-tree/nvim-tree.lua",
})
require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 50,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = false,
	},
	update_focused_file = {
		enable = true,
	},
})

-- Copilot keymap (loaded immediately)
vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
})

-- =============================================================================
-- KEYMAPS (Immediate)
-- =============================================================================

local formatting_cmd = '<Cmd>lua require("conform").format({ lsp_fallback = true })<CR>'

-- Exit insert mode
vim.keymap.set("i", "jk", "<Esc>")

-- Clear search highlighting with Escape in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Tab completion
vim.keymap.set("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
vim.keymap.set("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

-- Custom commands
nmap_leader("R", "<Cmd>ReplaceAfterCursor<CR>", "Find and replace after cursor")

-- Buffer keymaps
nmap_leader("[", "<C-w>w", "Switch to previous Window")
nmap_leader("]", "<C-w>w", "Switch to next Window")
nmap_leader("k", "<cmd>bdelete<CR>", "Close buffer")
nmap_leader("df", confirm_and_delete_buffer, "Delete current buffer")
nmap_leader("h", "<cmd>bprev<cr>", "Previous Buffer")
nmap_leader(";", "<cmd>bnext<cr>", "Next Buffer")
nmap_leader("w", "<cmd>w<CR>", "Save")
nmap_leader("q", "<cmd>wqall!<CR>", "Quit")

-- Filetree keymap
nmap_leader("o", "<cmd>NvimTreeToggle<cr>", "Toggle File Tree")

-- Package management keymaps
nmap_leader("pu", "<cmd>PackUpdate<cr>", "Update packages")
nmap_leader("pc", "<cmd>PackClean<cr>", "Clean inactive packages")

-- Git Keymap
nmap_leader("gc", "<Cmd>Git commit<CR>", "Commit")
nmap_leader("gC", "<Cmd>Git commit --amend<CR>", "Commit amend")
nmap_leader("gl", "<Cmd>Git log --oneline<CR>", "Log")
nmap_leader("gL", "<Cmd>Git log --oneline --follow -- %<CR>", "Log buffer")
nmap_leader("go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "Toggle overlay")
nmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at cursor")
nmap_leader("gh", "<Cmd>lua MiniGit.show_range_history()<CR>", "Show range history")
nmap_leader("g", "<cmd>LazyGit<cr>", "LazyGit")

-- LSP Keymaps
nmap_leader("la", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", "Arguments popup")
nmap_leader("ld", "<Cmd>lua vim.diagnostic.open_float()<CR>", "Diagnostics popup")

-- Shift+K: Show diagnostics if present, otherwise show hover
vim.keymap.set("n", "K", function()
	local line = vim.fn.line(".") - 1
	local bufnr = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
	if #diagnostics > 0 then
		vim.diagnostic.open_float({ scope = "line" })
	else
		vim.lsp.buf.hover()
	end
end, { desc = "Show diagnostic or hover info" })

nmap_leader("lf", formatting_cmd, "Format")
nmap_leader("li", "<Cmd>lua vim.lsp.buf.hover()<CR>", "Information")
nmap_leader("lj", "<Cmd>lua vim.diagnostic.goto_next()<CR>", "Next diagnostic")
nmap_leader("lk", "<Cmd>lua vim.diagnostic.goto_prev()<CR>", "Prev diagnostic")
nmap_leader("lR", "<Cmd>lua vim.lsp.buf.references()<CR>", "References")
nmap_leader("lr", "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename")
map("gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Source definition")
nmap_leader("ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", "Code action")
nmap_leader("m", "<cmd>Mason<CR>", "Mason LSP")
nmap_leader("li", "<cmd>LspInfo<CR>", "LSP Info")

-- Search Keymaps
nmap_leader("fa", '<Cmd>Pick git_hunks scope="staged"<CR>', "Added hunks (all)")
nmap_leader("fA", '<Cmd>Pick git_hunks path="%" scope="staged"<CR>', "Added hunks (current)")
nmap_leader("fb", "<Cmd>Pick buffers<CR>", "Buffers")
nmap_leader("fc", "<Cmd>Pick git_commits<CR>", "Commits (all)")
nmap_leader("fC", '<Cmd>Pick git_commits path="%"<CR>', "Commits (current)")
nmap_leader("fd", '<Cmd>Pick diagnostic scope="all"<CR>', "Diagnostic workspace")
nmap_leader("fD", '<Cmd>Pick diagnostic scope="current"<CR>', "Diagnostic buffer")
nmap_leader("ff", "<Cmd>Pick files<CR>", "Files")
nmap_leader("fg", "<Cmd>Pick grep_live<CR>", "Grep live")
nmap_leader("fG", '<Cmd>Pick grep pattern="<cword>"<CR>', "Grep current word")
nmap_leader("fh", "<Cmd>Pick help<CR>", "Help tags")
nmap_leader("fH", "<Cmd>Pick hl_groups<CR>", "Highlight groups")
nmap_leader("fl", '<Cmd>Pick buf_lines scope="all"<CR>', "Lines (all)")
nmap_leader("fL", '<Cmd>Pick buf_lines scope="current"<CR>', "Lines (current)")
nmap_leader("fm", "<Cmd>Pick git_hunks<CR>", "Modified hunks (all)")
nmap_leader("fM", '<Cmd>Pick git_hunks path="%"<CR>', "Modified hunks (current)")
nmap_leader("fr", '<Cmd>Pick lsp scope="references"<CR>', "References (LSP)")
nmap_leader("fs", '<Cmd>Pick lsp scope="workspace_symbol"<CR>', "Symbols workspace (LSP)")
nmap_leader("fS", '<Cmd>Pick lsp scope="document_symbol"<CR>', "Symbols buffer (LSP)")
nmap_leader("fv", '<Cmd>Pick visit_paths cwd=""<CR>', "Visit paths (all)")
nmap_leader("fV", "<Cmd>Pick visit_paths<CR>", "Visit paths (cwd)")

-- Package Info Keymaps
nmap_leader("nu", '<Cmd>lua require("package-info").update()<CR>', "Update current dependency")
nmap_leader("nd", '<Cmd>lua require("package-info").delete()<CR>', "Delete current dependency")

-- MiniFiles Keymaps
nmap_leader("ec", '<Cmd>lua MiniFiles.open(vim.fn.stdpath("config"))<CR>', "Config")
nmap_leader("ed", "<Cmd>lua MiniFiles.open()<CR>", "Directory")
nmap_leader("ef", "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>", "File directory")
nmap_leader("ei", "<Cmd>edit $MYVIMRC<CR>", "Edit init.lua")
nmap_leader(
	"em",
	'<Cmd>lua MiniFiles.open(vim.fn.stdpath("data").."/site/pack/core/opt/mini.nvim")<CR>',
	"Mini.nvim directory"
)
nmap_leader("ep", '<Cmd>lua MiniFiles.open(vim.fn.stdpath("data").."/site/pack/core/opt")<CR>', "Plugins directory")

-- =============================================================================
-- AUTOCOMMANDS (Immediate)
-- =============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Custom replace command
vim.api.nvim_create_user_command("ReplaceAfterCursor", function()
	local find = vim.fn.input("Find: ")
	local replace = vim.fn.input("Replace with: ")
	local flags = "gc"
	local line = vim.fn.line(".")
	local col = vim.fn.col(".")
	vim.cmd(line .. ",$s/" .. find .. "/" .. replace .. "/" .. flags)
	vim.fn.cursor(line, col)
end, {})

-- Package management commands
vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, { desc = "Update all packages" })

vim.api.nvim_create_user_command("PackClean", function()
	local inactive = {}
	for name, info in pairs(vim.pack.get()) do
		if not info.active then
			table.insert(inactive, name)
		end
	end
	if #inactive > 0 then
		vim.pack.del(inactive)
		print("Cleaned " .. #inactive .. " inactive plugin(s)")
	else
		print("No inactive plugins to clean")
	end
end, { desc = "Clean inactive packages" })

-- =============================================================================
-- SCHEDULED LOAD: Load after startup (lazy loading)
-- =============================================================================

later(function()
	-- Mini Bracketed
	require("mini.bracketed").setup()
end)

later(function()
	-- Mini Bufremove
	require("mini.bufremove").setup()
end)

later(function()
	-- Mini Comment (depends on ts_context_commentstring)
	vim.pack.add({
		"https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
	})
	require("mini.comment").setup({
		options = {
			custom_commentstring = function()
				return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
			end,
		},
	})
end)

later(function()
	-- Mini Cursorword
	require("mini.cursorword").setup()
end)

later(function()
	-- Mini Doc
	require("mini.doc").setup()
end)

later(function()
	-- Mini Git
	require("mini.git").setup()
end)

later(function()
	-- Mini Extra
	require("mini.extra").setup()
end)

later(function()
	-- Mini Align
	require("mini.align").setup()
end)

later(function()
	-- Mini Indentscope
	require("mini.indentscope").setup()
end)

later(function()
	-- Mini Splitjoin
	require("mini.splitjoin").setup()
end)

later(function()
	-- Mini Move
	require("mini.move").setup({ options = { reindent_linewise = false } })
end)

later(function()
	-- Mini Operators
	require("mini.operators").setup()
end)

later(function()
	-- Mini Trailspace
	require("mini.trailspace").setup()
end)

later(function()
	-- Mini Visits
	require("mini.visits").setup()
end)

later(function()
	-- Mini Fuzzy
	require("mini.fuzzy").setup()
end)

later(function()
	-- Mini AI
	local ai = require("mini.ai")
	ai.setup({
		custom_textobjects = {
			B = MiniExtra.gen_ai_spec.buffer(),
			F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		},
	})
end)

later(function()
	-- Mini Basics
	require("mini.basics").setup({
		options = {
			basic = false,
		},
		mappings = {
			windows = true,
			move_with_alt = true,
		},
	})
	vim.o.winblend = 0
end)

later(function()
	-- Mini Diff
	require("mini.diff").setup()

	local rhs = function()
		return MiniDiff.operator("yank") .. "gh"
	end

	vim.keymap.set("n", "ghy", rhs, { expr = true, remap = true, desc = "Copy hunk's reference lines" })
end)

later(function()
	-- Mini Files
	require("mini.files").setup({ windows = { preview = false } })

	local minifiles_augroup = vim.api.nvim_create_augroup("ec-mini-files", {})

	vim.api.nvim_create_autocmd("User", {
		group = minifiles_augroup,
		pattern = "MiniFilesWindowOpen",
		callback = function(args)
			vim.api.nvim_win_set_config(args.data.win_id, { border = "double" })
		end,
	})
end)

later(function()
	-- Mini Hipatterns
	local hipatterns = require("mini.hipatterns")
	local hi_words = MiniExtra.gen_highlighter.words

	-- Returns hex color group for matching rgba() color
	local rgba_color = function(_, match)
		local style = "bg"
		local red, green, blue, alpha = match:match("rgba%((%d+), ?(%d+), ?(%d+), ?(%d*%.?%d*)%)")
		alpha = tonumber(alpha)
		if alpha == nil or alpha < 0 or alpha > 1 then
			return false
		end
		local hex = string.format("#%02x%02x%02x", red * alpha, green * alpha, blue * alpha)
		return hipatterns.compute_hex_color_group(hex, style)
	end

	hipatterns.setup({
		highlighters = {
			fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
			hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
			todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
			note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

			hex_color = hipatterns.gen_highlighter.hex_color(),
			rgba_color = {
				pattern = "rgba%(%d+, ?%d+, ?%d+, ?%d*%.?%d*%)",
				group = rgba_color,
			},
		},
	})
end)

later(function()
	-- Mini Misc auto root
	MiniMisc.setup_auto_root()
end)

later(function()
	-- Mini Pick
	require("mini.pick").setup({
		window = { config = { border = "double" } },
	})

	vim.ui.select = MiniPick.ui_select
	vim.keymap.set("n", "f/", [[<Cmd>Pick buf_lines scope='current'<CR>]], { nowait = true })
end)

later(function()
	-- Mini Surround
	require("mini.surround").setup({ search_method = "cover_or_next" })
	vim.keymap.set({ "n", "x" }, "s", "<Nop>")
end)

-- Package Info
later(function()
	vim.pack.add({
		"https://github.com/MunifTanjim/nui.nvim",
		"https://github.com/vuki656/package-info.nvim",
	})
	require("package-info").setup({
		highlights = {
			up_to_date = {
				fg = "#0DB9D7",
			},
			outdated = {
				fg = "#d19a66",
			},
		},
		package_manager = "pnpm",
	})

	vim.cmd([[highlight PackageInfoUpToDateVersion guifg=]] .. "#0DB9D7")
	vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. "#d19a66")
end)

-- Treesitter
later(function()
	vim.pack.add({
		{
			src = "https://github.com/nvim-treesitter/nvim-treesitter",
			version = "master",
		},
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	})

	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"html",
			"lua",
			"markdown",
			"markdown_inline",
			"query",
			"vim",
			"vimdoc",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = { enable = true, disable = { "ruby" } },
	})
end)

-- GitSigns
later(function()
	vim.pack.add({
		"https://github.com/lewis6991/gitsigns.nvim",
	})
	require("gitsigns").setup({
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
	})
end)

-- LSP
later(function()
	vim.pack.add({
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/williamboman/mason.nvim",
		"https://github.com/williamboman/mason-lspconfig.nvim",
	})

	require("mason").setup({})
	require("mason-lspconfig").setup({
		ensure_installed = { "vtsls", "tailwindcss", "lua_ls" },
		automatic_installation = true,
	})

	-- Configure LSP servers before enabling them
	-- vim.lsp.config("vtsls", {
	-- 	settings = {
	-- 		typescript = {
	-- 			preferences = {
	-- 				importModuleSpecifier = "relative",
	-- 			},
	-- 		},
	-- 	},
	-- })

	vim.lsp.config("tailwindcss", {
		settings = {
			tailwindCSS = {
				experimental = {
					classRegex = {
						{ "cva\\(([^)]*)\\)", "[\"'`\\]([^\"'`]*).*?[\"'`\\]" },
						{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
						{ "cn\\(([^)]*)\\)", "[\"'`\\]([^\"'`]*).*?[\"'`\\]" },
						{ "([a-zA-Z0-9\\-:_]+)" },
					},
				},
			},
		},
	})

	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
			},
		},
	})

	-- Enable LSP servers
	vim.lsp.enable({ "vtsls", "tailwindcss", "lua_ls" })
end)

-- Formatting
later(function()
	vim.pack.add({
		"https://github.com/stevearc/conform.nvim",
	})
	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			local disable_filetypes = { c = true, cpp = true }
			return {
				timeout_ms = 500,
				lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			htmlangular = { "prettierd", "prettier", stop_after_first = true },
		},
	})
end)

-- LazyGit
later(function()
	vim.pack.add({
		"https://github.com/nvim-lua/plenary.nvim",
		{
			src = "https://github.com/kdheepak/lazygit.nvim",
		},
	})
end)

-- Flash
later(function()
	vim.pack.add({
		"https://github.com/folke/flash.nvim",
	})

	vim.keymap.set({ "n", "x", "o" }, "s", function()
		require("flash").jump()
	end, { desc = "Flash Jump" })

	vim.keymap.set({ "n", "x", "o" }, "S", function()
		require("flash").treesitter()
	end, { desc = "Flash Treesitter" })
end)

-- Mini Completion (load early so it's ready when LSP attaches)
later(function()
	vim.opt.iskeyword:append("-")

	require("mini.completion").setup({
		fallback_action = "<C-x><C-n>",
		set_vim_setting = true,
		lsp_completion = {
			source_func = "omnifunc",
			auto_setup = true,
			process_items = function(items, base)
				items = vim.tbl_filter(function(x)
					return x.kind ~= 1 and x.kind ~= 15
				end, items)

				return MiniCompletion.default_process_items(items, base)
			end,
		},
		window = {
			info = { border = "double" },
			signature = { border = "double" },
		},
	})

	-- Custom CR action for completion
	_G.cr_action = function()
		if vim.fn.complete_info()["selected"] ~= -1 then
			return "\25"
		end
		return "\r"
	end

	vim.keymap.set("i", "<CR>", "v:lua.cr_action()", { expr = true })
end)

-- =============================================================================
-- NOTES
-- =============================================================================
-- Package management:
--   <leader>pu - Update all packages (opens confirmation buffer)
--   <leader>pc - Clean inactive packages
--   :PackUpdate - Same as <leader>pu
--   :PackClean - Same as <leader>pc
--   :lua vim.pack.update() - Update with confirmation
--   :lua vim.pack.update(nil, { force = true }) - Update without confirmation
--   :lua vim.pack.del({ 'plugin-name' }) - Delete specific plugin(s)
