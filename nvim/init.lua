-- Application Config
local H = {}

H.keys = {
	["cr"] = vim.api.nvim_replace_termcodes("<CR>", true, true, true),
	["ctrl-y"] = vim.api.nvim_replace_termcodes("<C-y>", true, true, true),
	["ctrl-y_cr"] = vim.api.nvim_replace_termcodes("<C-y><CR>", true, true, true),
}

_G.Config = {
	path_package = vim.fn.stdpath("data") .. "/site/",
}

-- Setup Mini
local mini_path = Config.path_package .. "pack/deps/start/mini.nvim"

if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/echasnovski/mini.nvim", mini_path }
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

require("mini.deps").setup({ path = { package = Config.path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Functions
Config.cr_action = function()
	if vim.fn.pumvisible() ~= 0 then
		local item_selected = vim.fn.complete_info()["selected"] ~= -1
		return item_selected and H.keys["ctrl-y"] or H.keys["ctrl-y_cr"]
	else
		return require("mini.pairs").cr()
	end
end

-- Map leader keys
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

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Mini.nvim ==================================================================
add({ name = "mini.nvim", checkout = "HEAD" })

-- General settings
now(function()
	-- Angular Highlighting
	vim.filetype.add({
		pattern = {
			[".*%.component%.html"] = "htmlangular",
		},
	})

	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.o.statuscolumn = "%s %l %r"
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
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	vim.opt.termguicolors = true
	vim.opt.completeopt = "menu,menuone,noinsert"
	vim.o.tabstop = 2 -- A TAB character looks like 4 spaces
	vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
	vim.o.softtabstop = 2 -- Number of spaces inserted instead of a TAB character
	vim.o.shiftwidth = 2 -- Number of spaces inserted when indenting
end)

-- Keymaps
now(function()
	local formatting_cmd = '<Cmd>lua require("conform").format({ lsp_fallback = true })<CR>'

	-- Exit insert mode
	vim.keymap.set("i", "jk", "<Esc>")

	local imap_expr = function(lhs, rhs)
		vim.keymap.set("i", lhs, rhs, { expr = true })
	end

	imap_expr("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
	imap_expr("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])

	-- Buffer keymaps
	nmap_leader("[", "<C-w>w", "Switch to previous Window")
	nmap_leader("]", "<C-w>w", "Switch to next Window")
	nmap_leader("k", "<cmd>bdelete<CR>", "Close buffer")
	nmap_leader("h", "<cmd>bprev<cr>", "Previous Buffer")
	nmap_leader(";", "<cmd>bnext<cr>", "Next Buffer")
	nmap_leader("w", "<cmd>w<CR>", "Save")
	nmap_leader("q", "<cmd>wqall!<CR>", "Quit")

	-- Filetree keymap
	nmap_leader("o", "<cmd>NvimTreeToggle<cr>", "Toggle File Tree")

	-- Package management keymap
	nmap_leader("pu", "<cmd>DepsUpdate<cr>", "Update Deps")
	nmap_leader("pc", "<cmd>DepsClean<cr>", "Clean Deps")

	-- Git Keymap
	nmap_leader("gc", "<Cmd>Git commit<CR>", "Commit")
	nmap_leader("gC", "<Cmd>Git commit --amend<CR>", "Commit amend")
	nmap_leader("gl", "<Cmd>Git log --oneline<CR>", "Log")
	nmap_leader("gL", "<Cmd>Git log --oneline --follow -- %<CR>", "Log buffer")
	nmap_leader("go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "Toggle overlay")
	nmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at cursor")
	nmap_leader("lc", "<Cmd>GitConflictListQf<cr>", "List Conflicts")
	nmap_leader("gb", "<Cmd>GitBlameCopySHA<cr>", "Open Git Blame Commit")

	-- LSP Keymaps
	nmap_leader("la", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", "Arguments popup")
	nmap_leader("ld", "<Cmd>lua vim.diagnostic.open_float()<CR>", "Diagnostics popup")
	nmap_leader("lf", formatting_cmd, "Format")
	nmap_leader("li", "<Cmd>lua vim.lsp.buf.hover()<CR>", "Information")
	nmap_leader("lj", "<Cmd>lua vim.diagnostic.goto_next()<CR>", "Next diagnostic")
	nmap_leader("lk", "<Cmd>lua vim.diagnostic.goto_prev()<CR>", "Prev diagnostic")
	nmap_leader("lR", "<Cmd>lua vim.lsp.buf.references()<CR>", "References")
	nmap_leader("lr", "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename")
	map("gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Source definition")
	nmap_leader("ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", "Code action")
	nmap_leader("m", "<cmd>Mason<CR>", "Mason LSP")

	-- Search Keymaps
	nmap_leader("f/", '<Cmd>Pick history scope="/"<CR>', '"/" history')
	nmap_leader("f:", '<Cmd>Pick history scope=":"<CR>', '":" history')
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

	-- MiniFiles Keymaps
	nmap_leader("ec", '<Cmd>lua MiniFiles.open(vim.fn.stdpath("config"))<CR>', "Config")
	nmap_leader("ed", "<Cmd>lua MiniFiles.open()<CR>", "Directory")
	nmap_leader("ef", "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>", "File directory")
	nmap_leader("ei", "<Cmd>edit $MYVIMRC<CR>", "File directory")
	nmap_leader(
		"em",
		'<Cmd>lua MiniFiles.open(vim.fn.stdpath("data").."/site/pack/deps/start/mini.nvim")<CR>',
		"Mini.nvim directory"
	)
	nmap_leader("ep", '<Cmd>lua MiniFiles.open(vim.fn.stdpath("data").."/site/pack/deps/opt")<CR>', "Plugins directory")

	-- Terminal
	nmap_leader("tt", "<cmd>ToggleTerm direction=float<cr>", "Open floating terminal")
	vim.keymap.set("t", "jk", [[<C-\><C-n>]])

	-- MiniMap
	nmap_leader("zc", "<Cmd>lua MiniMap.close()<CR>", "Close")
	nmap_leader("zf", "<Cmd>lua MiniMap.toggle_focus()<CR>", "Focus (toggle)")
	nmap_leader("zo", "<Cmd>lua MiniMap.open()<CR>", "Open")
	nmap_leader("zr", "<Cmd>lua MiniMap.refresh()<CR>", "Refresh")
	nmap_leader("zs", "<Cmd>lua MiniMap.toggle_side()<CR>", "Side (toggle)")
	nmap_leader("zt", "<Cmd>lua MiniMap.toggle()<CR>", "Toggle")
end)

-- Colorscheme
now(function()
	add("rebelot/kanagawa.nvim")
	vim.o.background = "dark"
	vim.cmd.colorscheme("kanagawa-dragon")
	vim.api.nvim_set_hl(0, "DiffText", { fg = "#ffffff", bg = "#1d3b40" })
	vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#ffffff", bg = "#1d3450" })
end)

-- Mini Deps ===============================================================
now(function()
	require("mini.notify").setup()
	vim.notify = require("mini.notify").make_notify()
end)

now(function()
	require("mini.sessions").setup()
end)

now(function()
	require("mini.statusline").setup()
end)

now(function()
	require("mini.tabline").setup()
end)

later(function()
	require("mini.bracketed").setup()
end)

later(function()
	require("mini.bufremove").setup()
end)

later(function()
	require("mini.comment").setup()
end)

later(function()
	require("mini.cursorword").setup()
end)

later(function()
	require("mini.doc").setup()
end)

later(function()
	require("mini.git").setup()
end)

later(function()
	require("mini.extra").setup()
end)

later(function()
	require("mini.align").setup()
end)

later(function()
	require("mini.indentscope").setup()
end)

later(function()
	require("mini.jump").setup()
end)

later(function()
	require("mini.jump2d").setup({ view = { dim = true } })
end)

later(function()
	require("mini.splitjoin").setup()
end)

later(function()
	require("mini.move").setup({ options = { reindent_linewise = false } })
end)

later(function()
	require("mini.operators").setup()
end)

later(function()
	require("mini.trailspace").setup()
end)

later(function()
	require("mini.visits").setup()
end)

now(function()
	require("mini.icons").setup()
	MiniIcons.mock_nvim_web_devicons()
end)

later(function()
	require("mini.fuzzy").setup()
end)

later(function()
	require("mini.map").setup()

	local map = require("mini.map")
	local gen_integr = map.gen_integration
	local encode_symbols = map.gen_encode_symbols.block("3x2")

	if vim.startswith(vim.fn.getenv("TERM"), "st") then
		encode_symbols = map.gen_encode_symbols.dot("4x2")
	end

	map.setup({
		symbols = { encode = encode_symbols },
		integrations = { gen_integr.builtin_search(), gen_integr.diff(), gen_integr.diagnostic() },
	})

	vim.keymap.set("n", [[\h]], ":let v:hlsearch = 1 - v:hlsearch<CR>", { desc = "Toggle hlsearch" })

	for _, key in ipairs({ "n", "N", "*" }) do
		vim.keymap.set("n", key, key .. "zv<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>")
	end
end)

later(function()
	local ai = require("mini.ai")
	ai.setup({
		custom_textobjects = {
			B = MiniExtra.gen_ai_spec.buffer(),
			F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		},
	})
end)

later(function()
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
end)

later(function()
	require("mini.diff").setup()

	local rhs = function()
		return MiniDiff.operator("yank") .. "gh"
	end

	vim.keymap.set("n", "ghy", rhs, { expr = true, remap = true, desc = "Copy hunk's reference lines" })
end)

later(function()
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
	local hipatterns = require("mini.hipatterns")
	local hi_words = MiniExtra.gen_highlighter.words
	hipatterns.setup({
		highlighters = {
			fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
			hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
			todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
			note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})
end)

later(function()
	require("mini.misc").setup({ make_global = { "put", "put_text", "stat_summary", "bench_time" } })
	MiniMisc.setup_auto_root()
end)

later(function()
	require("mini.pairs").setup({ modes = { insert = true, command = true, terminal = true } })
	vim.keymap.set("i", "<CR>", "v:lua.Config.cr_action()", { expr = true })
end)

later(function()
	require("mini.pick").setup({ window = { config = { border = "double" } } })

	vim.ui.select = MiniPick.ui_select
end)

later(function()
	require("mini.surround").setup({ search_method = "cover_or_next" })
	vim.keymap.set({ "n", "x" }, "s", "<Nop>")
end)

-- Dependencies ===============================================================

-- Git Conflicts
later(function()
	add({ source = "akinsho/git-conflict.nvim", version = "*", config = true })
	require("git-conflict").setup()
end)

-- Package.json package info
later(function()
	add({ source = "vuki656/package-info.nvim", depends = { "MunifTanjim/nui.nvim" }, ft = "json" })
	require("package-info").setup({
		colors = {
			up_to_date = "#0DB9D7",
			outdated = "#d19a66",
		},
	})

	vim.cmd([[highlight PackageInfoUpToDateVersion guifg=]] .. "#0DB9D7")
	vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. "#d19a66")
end)

-- GitBlame inline
later(function()
	add("f-person/git-blame.nvim")
	require("gitblame").setup({
		enabled = true,
		message_template = " <summary> • <date> • <author>",
		date_format = "%m-%d-%Y",
		virtual_text_column = 1,
	})
end)

-- NvimTree
now(function()
	add("nvim-tree/nvim-tree.lua")
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
end)

-- Treesitter
later(function()
	local ts_spec = {
		source = "nvim-treesitter/nvim-treesitter",
		checkout = "master",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	}

	add({ source = "nvim-treesitter/nvim-treesitter-textobjects", depends = { ts_spec } })

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
	add("lewis6991/gitsigns.nvim")
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

-- GitHub Copilot
later(function()
	add("github/copilot.vim")
	vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
		expr = true,
		replace_keycodes = false,
	})
	vim.g.copilot_no_tab_map = true
end)

-- LSP
later(function()
	add("neovim/nvim-lspconfig")
	add("williamboman/mason.nvim")
	add("williamboman/mason-lspconfig.nvim")

	local lspconfig = require("lspconfig")

	local on_attach_custom = function(client, buf_id)
		vim.bo[buf_id].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"

		if vim.fn.has("nvim-0.8") == 1 then
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
		else
			client.resolved_capabilities.document_formatting = false
			client.resolved_capabilities.document_range_formatting = false
		end
	end

	require("mason").setup({})
	require("mason-lspconfig").setup({
		ensure_installed = { "ts_ls", "angularls", "tailwindcss" },
		automatic_installation = true,
	})

	require("mason-lspconfig").setup_handlers({
		function(server)
			lspconfig[server].setup({
				on_attach = on_attach_custom,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			})
		end,
	})
end)

-- Formatting
later(function()
	add("stevearc/conform.nvim")
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
			typescriptreact = { "prettierd" },
			css = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			htmlangular = { "prettierd", "prettier", stop_after_first = true },
			heex = { "mix" },
			surface = { "mix" },
		},
	})
end)

-- Toggle Term
later(function()
	add({ source = "akinsho/toggleterm.nvim", version = "*", config = true })
	require("toggleterm").setup()
end)
