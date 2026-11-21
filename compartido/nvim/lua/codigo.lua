-- Colores del CODIGO (sintaxis), con paletas a eleccion.
-- La interfaz (fondo, barra, menus, numeros) sigue saliendo de colors/tema.lua,
-- que reescribe set-theme.sh. Este archivo no lo toca nadie.
--
--   :Codigo <Tab>        lista las paletas
--   :Codigo kanagawa     aplica y recuerda la paleta
--
-- La eleccion se guarda en ~/.local/state/nvim/codigo-paleta.
-- Para agregar una paleta: copia un bloque de abajo y cambia los colores.

local M = {}

-- Cada paleta define los mismos roles:
--   fg texto normal | comment comentarios | keyword if/def/return | func funciones
--   prop campos y propiedades | key claves de yaml/json/toml | type tipos
--   string textos | const numeros y constantes | param parametros
--   builtin self/this/print | special escapes \n | op operadores | punct puntuacion
M.paletas = {
    tokyonight = {
        fg = "#c0caf5", comment = "#636da6", keyword = "#bb9af7", func = "#7aa2f7",
        prop = "#7dcfff", key = "#73daca", type = "#2ac3de", string = "#9ece6a",
        const = "#ff9e64", param = "#e0af68", builtin = "#f7768e", special = "#ff007c",
        op = "#89ddff", punct = "#9aa5ce",
    },
    catppuccin = {
        fg = "#cdd6f4", comment = "#7f849c", keyword = "#cba6f7", func = "#89b4fa",
        prop = "#b4befe", key = "#89b4fa", type = "#f9e2af", string = "#a6e3a1",
        const = "#fab387", param = "#eba0ac", builtin = "#f38ba8", special = "#f5c2e7",
        op = "#89dceb", punct = "#9399b2",
    },
    kanagawa = {
        fg = "#dcd7ba", comment = "#727169", keyword = "#957fb8", func = "#7e9cd8",
        prop = "#e6c384", key = "#7fb4ca", type = "#7aa89f", string = "#98bb6c",
        const = "#ffa066", param = "#b8b4d0", builtin = "#e46876", special = "#d27e99",
        op = "#c0a36e", punct = "#9cabca",
    },
    ["rose-pine"] = {
        fg = "#e0def4", comment = "#6e6a86", keyword = "#3e8fb0", func = "#ebbcba",
        prop = "#9ccfd8", key = "#c4a7e7", type = "#9ccfd8", string = "#f6c177",
        const = "#eb6f92", param = "#c4a7e7", builtin = "#eb6f92", special = "#c4a7e7",
        op = "#908caa", punct = "#908caa",
    },
    gruvbox = {
        fg = "#ebdbb2", comment = "#928374", keyword = "#fb4934", func = "#8ec07c",
        prop = "#83a598", key = "#83a598", type = "#fabd2f", string = "#b8bb26",
        const = "#d3869b", param = "#83a598", builtin = "#fe8019", special = "#fe8019",
        op = "#fe8019", punct = "#a89984",
    },
    dracula = {
        fg = "#f8f8f2", comment = "#6272a4", keyword = "#ff79c6", func = "#50fa7b",
        prop = "#8be9fd", key = "#8be9fd", type = "#8be9fd", string = "#f1fa8c",
        const = "#bd93f9", param = "#ffb86c", builtin = "#bd93f9", special = "#ff79c6",
        op = "#ff79c6", punct = "#bfbfbf",
    },
    nord = {
        fg = "#d8dee9", comment = "#616e88", keyword = "#81a1c1", func = "#88c0d0",
        prop = "#8fbcbb", key = "#8fbcbb", type = "#8fbcbb", string = "#a3be8c",
        const = "#b48ead", param = "#ebcb8b", builtin = "#81a1c1", special = "#ebcb8b",
        op = "#81a1c1", punct = "#eceff4",
    },
    everforest = {
        fg = "#d3c6aa", comment = "#859289", keyword = "#e67e80", func = "#a7c080",
        prop = "#7fbbb3", key = "#7fbbb3", type = "#dbbc7f", string = "#83c092",
        const = "#d699b6", param = "#e69875", builtin = "#e69875", special = "#e69875",
        op = "#e69875", punct = "#9da9a0",
    },
    onedark = {
        fg = "#abb2bf", comment = "#7f848e", keyword = "#c678dd", func = "#61afef",
        prop = "#e06c75", key = "#e06c75", type = "#e5c07b", string = "#98c379",
        const = "#d19a66", param = "#e06c75", builtin = "#e5c07b", special = "#56b6c2",
        op = "#56b6c2", punct = "#abb2bf",
    },
}

local archivo = vim.fn.stdpath("state") .. "/codigo-paleta"
local por_defecto = "tokyonight"

local function guardada()
    local ok, lineas = pcall(vim.fn.readfile, archivo)
    local nombre = ok and lineas[1] or nil
    return M.paletas[nombre] and nombre or por_defecto
end

local function grupos(c)
    return {
        -- sintaxis clasica (cuando no hay treesitter)
        Comment     = { fg = c.comment, italic = true },
        Constant    = { fg = c.const },
        String      = { fg = c.string },
        Character   = { fg = c.string },
        Number      = { fg = c.const },
        Boolean     = { fg = c.const },
        Float       = { fg = c.const },
        Identifier  = { fg = c.fg },
        Function    = { fg = c.func },
        Statement   = { fg = c.keyword },
        Keyword     = { fg = c.keyword },
        Conditional = { fg = c.keyword },
        Repeat      = { fg = c.keyword },
        Operator    = { fg = c.op },
        PreProc     = { fg = c.keyword },
        Include     = { fg = c.keyword },
        Type        = { fg = c.type },
        Special     = { fg = c.special },
        Delimiter   = { fg = c.punct },
        Todo        = { fg = "#111111", bg = c.param, bold = true },

        -- treesitter
        ["@variable"]              = { fg = c.fg },
        ["@variable.parameter"]    = { fg = c.param },
        ["@variable.member"]       = { fg = c.prop },
        ["@variable.builtin"]      = { fg = c.builtin, italic = true },
        ["@property"]              = { fg = c.prop },
        ["@field"]                 = { fg = c.prop },
        ["@function"]              = { fg = c.func },
        ["@function.call"]         = { fg = c.func },
        ["@function.method"]       = { fg = c.func },
        ["@function.method.call"]  = { fg = c.func },
        ["@function.builtin"]      = { fg = c.builtin },
        ["@constructor"]           = { fg = c.type },
        ["@type"]                  = { fg = c.type },
        ["@type.builtin"]          = { fg = c.type, italic = true },
        ["@constant"]              = { fg = c.const },
        ["@constant.builtin"]      = { fg = c.const, bold = true },
        ["@number"]                = { fg = c.const },
        ["@boolean"]               = { fg = c.const },
        ["@module"]                = { fg = c.param },
        ["@namespace"]             = { fg = c.param },
        ["@attribute"]             = { fg = c.param },
        ["@label"]                 = { fg = c.func },
        ["@keyword"]               = { fg = c.keyword, italic = true },
        ["@keyword.function"]      = { fg = c.keyword },
        ["@keyword.return"]        = { fg = c.keyword },
        ["@keyword.import"]        = { fg = c.keyword },
        ["@keyword.operator"]      = { fg = c.keyword },
        ["@keyword.conditional"]   = { fg = c.keyword },
        ["@keyword.repeat"]        = { fg = c.keyword },
        ["@operator"]              = { fg = c.op },
        ["@string"]                = { fg = c.string },
        ["@string.escape"]         = { fg = c.special },
        ["@string.special"]        = { fg = c.special },
        ["@string.regexp"]         = { fg = c.special },
        ["@punctuation.bracket"]   = { fg = c.punct },
        ["@punctuation.delimiter"] = { fg = c.punct },
        ["@punctuation.special"]   = { fg = c.op },
        ["@comment"]               = { link = "Comment" },
        ["@tag"]                   = { fg = c.keyword },
        ["@tag.attribute"]         = { fg = c.param },
        ["@tag.delimiter"]         = { fg = c.punct },

        -- archivos de configuracion: claves con color propio
        ["@property.yaml"]         = { fg = c.key },
        ["@property.json"]         = { fg = c.key },
        ["@property.toml"]         = { fg = c.key },

        -- markdown
        ["@markup.heading"]        = { fg = c.func, bold = true },
        ["@markup.strong"]         = { bold = true },
        ["@markup.italic"]         = { italic = true },
        ["@markup.raw"]            = { fg = c.string },
        ["@markup.link.url"]       = { fg = c.prop, underline = true },
        ["@markup.list"]           = { fg = c.const },
    }
end

-- Aplica una paleta (o la guardada si no se indica)
function M.aplicar(nombre)
    nombre = nombre or guardada()
    for grupo, opciones in pairs(grupos(M.paletas[nombre])) do
        vim.api.nvim_set_hl(0, grupo, opciones)
    end
end

vim.api.nvim_create_user_command("Codigo", function(args)
    local nombre = args.args
    if nombre == "" then
        vim.notify("paleta actual: " .. guardada())
        return
    end
    if not M.paletas[nombre] then
        vim.notify("no existe la paleta: " .. nombre, vim.log.levels.ERROR)
        return
    end
    vim.fn.mkdir(vim.fn.fnamemodify(archivo, ":h"), "p")
    vim.fn.writefile({ nombre }, archivo)
    M.aplicar(nombre)
    vim.notify("paleta del codigo: " .. nombre)
end, {
    nargs = "?",
    desc = "elegir la paleta de colores del codigo",
    complete = function(lead)
        local nombres = vim.tbl_keys(M.paletas)
        table.sort(nombres)
        return vim.tbl_filter(function(n) return n:find(lead, 1, true) == 1 end, nombres)
    end,
})

return M
