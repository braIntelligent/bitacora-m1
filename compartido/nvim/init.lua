-- bitacora-m1: Neovim liviano (lazy.nvim + treesitter), con los colores del tema activo.
-- (La linea de arriba la usa instalar.sh para saber que este archivo es el suyo.)
-- Los colores salen de colors/tema.lua, que escribe set-theme.sh al cambiar de tema.
-- Si prefieres NvChad: sh extras/instalar-nvchad.sh (respalda esta configuracion).

vim.g.mapleader = " "

-- ---- gestor de plugins: lazy.nvim (se instala solo la 1a vez) ----
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ---- plugins ----
require("lazy").setup({
    -- Treesitter: resaltado por arbol sintactico. Los grupos @captura linkean a
    -- los grupos estandar (Function, Keyword, String...) que define tema.lua, asi
    -- que respeta los colores del tema activo.
    -- Rama main (la mantenida; master quedo congelada y rompe con nvim 0.12 en
    -- HTML/Markdown). Necesita tree-sitter-cli y un compilador de C.
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")
            ts.install({
                "python", "lua", "bash", "json", "yaml", "toml",
                "markdown", "markdown_inline", "javascript", "typescript",
                "tsx", "html", "css", "dockerfile", "hcl", "go",
                "vim", "vimdoc", "gitcommit", "diff",
                "perl", "php", "c", "ruby", "sql", "xml",
            })
            -- al abrir un archivo: resaltado + indentado por treesitter; si falta el
            -- parser y existe, lo instala y lo activa al terminar
            local function activar(buf, lang)
                if not pcall(vim.treesitter.start, buf, lang) then return false end
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                return true
            end
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(a)
                    local lang = vim.treesitter.language.get_lang(a.match) or a.match
                    if activar(a.buf, lang) then return end
                    if vim.tbl_contains(ts.get_available(), lang) then
                        ts.install(lang):await(function()
                            vim.schedule(function()
                                if vim.api.nvim_buf_is_valid(a.buf) then activar(a.buf, lang) end
                            end)
                        end)
                    end
                end,
            })
        end,
    },
}, { ui = { border = "rounded" } })

local o = vim.opt
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.termguicolors = true
o.mouse = "a"
o.clipboard = "unnamedplus"     -- copiar y pegar usan el portapapeles del sistema
-- Linux sin portapapeles (Kali en OrbStack, SSH): copiar viaja a la terminal por
-- OSC 52 y llega al portapapeles del Mac; pegar usa lo ultimo copiado en nvim.
if vim.fn.has("mac") == 0 and vim.env.DISPLAY == nil and vim.env.WAYLAND_DISPLAY == nil then
    local osc52 = require("vim.ui.clipboard.osc52")
    local function local_paste() return { vim.fn.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') } end
    vim.g.clipboard = {
        name = "osc52",
        copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
        paste = { ["+"] = local_paste, ["*"] = local_paste },
    }
end
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.wrap = true
o.linebreak = true              -- corta por palabra, no a mitad de palabra
o.breakindent = true            -- las lineas cortadas respetan la indentacion
o.scrolloff = 6
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 300
o.showmode = false              -- el modo ya sale en la barra de abajo
o.laststatus = 3                -- una sola barra de estado para todas las ventanas
o.fillchars = { eob = " " }     -- sin "~" en las lineas vacias del final
o.completeopt = { "menuone", "noselect", "popup" }

-- Interfaz con el tema activo (tema.lua) y el codigo con su propia paleta (lua/codigo.lua).
-- El autocmd la vuelve a aplicar si el tema se recarga.
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function() require("codigo").aplicar() end,
})
pcall(vim.cmd.colorscheme, "tema")

-- ^M: archivos con finales de linea mezclados (Windows + Unix, ej. reportes de
-- joomscan) muestran ^M. Se ocultan (conceal) sin tocar el archivo.
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost" }, {
    callback = function()
        if vim.w.cr_oculto or vim.fn.search("\\r$", "nw") == 0 then return end
        vim.fn.matchadd("Conceal", "\\r$", 10, -1, { conceal = "" })
        vim.wo.conceallevel = 2
        vim.wo.concealcursor = "nvic"
        vim.w.cr_oculto = true
    end,
})

-- Barra de estado: modo, archivo y posicion, con los colores del tema
local modos = {
    n = "NORMAL", i = "INSERTAR", v = "VISUAL", V = "V-LINEA", ["\22"] = "V-BLOQUE",
    c = "COMANDO", R = "REEMPLAZAR", t = "TERMINAL", s = "SELECCION",
}
function _G.barra_estado()
    local m = modos[vim.fn.mode()] or vim.fn.mode()
    return table.concat({
        "%#StatusLineModo# ", m, " %#StatusLine# %f %m%r%=",
        "%{&filetype} ", "%#StatusLineModo# %l:%c %#StatusLine#",
    })
end
o.statusline = "%!v:lua.barra_estado()"

-- Atajos (la tecla lider es Espacio)
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>write<cr>", { desc = "guardar" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "cerrar" })
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "explorador de archivos" })
map("n", "<leader>b", "<cmd>buffers<cr>:buffer ", { desc = "cambiar de archivo abierto" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "quitar el resaltado de la busqueda" })
map("n", "<C-h>", "<C-w>h"); map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k"); map("n", "<C-l>", "<C-w>l")
map("v", "<", "<gv"); map("v", ">", ">gv")      -- seguir indentando sin perder la seleccion

-- Resaltar un instante lo que se copia
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- En kitty, quitar el margen de la terminal mientras Neovim esta abierto, para que
-- el archivo llegue hasta los bordes; al salir vuelve. (kitty.conf permite solo esa orden.)
if vim.env.KITTY_WINDOW_ID and not vim.env.TMUX then
    local function margen(valor)
        vim.fn.system({ "kitty", "@", "set-spacing", "padding=" .. valor })
    end
    vim.api.nvim_create_autocmd("VimEnter", { callback = function() margen("0") end })
    vim.api.nvim_create_autocmd("VimLeavePre", { callback = function() margen("default") end })
end
