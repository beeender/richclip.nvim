local api = require("richclip.api")

local M = {}
M.config = require("richclip.config")

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
        api.copy(is_primary, { text_selection, html_selection })
    end
end

function M.init()
    require("richclip.cmd").init()
    vim.g.clipboard = {
        name = 'richclip',
        copy = {
            ['+'] = require('richclip').copy('+'),
            ['*'] = require('richclip').copy('*')
        },
        paste = {
            ['+'] = { M.config.get_richclip_exe_path(), 'paste' },
            ['*'] = { M.config.get_richclip_exe_path(), 'paste', '--primary' },
        }
    }
end

return M
