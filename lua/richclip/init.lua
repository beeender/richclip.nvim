local api = require("richclip.api")

local M = {}
M.config = require("richclip.config")

---Return the callback to be used by `vim.g.clipboard.copy`.
function M.copy(reg)
    local is_primary = (reg == '*')
    local text_mime_types = {
        "text/plain:charset=utf-8",
        "UTF8_STRING",
        "text/plain",
        "TEXT",
    }
    return function(lines)
        local html_selection = {
            lines = api.selection_to_html(),
            mime_types = { "text/html" }
        }
        local text_selection = {
            lines = lines,
            mime_types = text_mime_types
        }
        api.to_clip(is_primary, { text_selection, html_selection })
    end
end

---Return the callback to be used by `vim.g.clipboard.paste`.
function M.paste(reg)
    return function()
        local is_primary = (reg == '*')
        return api.from_clip(is_primary, nil)
    end
end

function M.init()
    require("richclip.cmd").init()
    vim.g.clipboard = {
        name = 'richclip',
        copy = {
            ['+'] = M.copy('+'),
            ['*'] = M.copy('*'),
        },
        paste = {
            ['+'] = M.paste('+'),
            ['*'] = M.paste('*'),
        }
    }
end

return M
