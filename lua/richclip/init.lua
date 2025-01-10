local api = require("richclip.api")
local utils = require("richclip.utils")
local config = require("richclip.config")

local M = {}

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function M.setup(options)
    if options == nil then
        options = {}
    end
    config.with_defaults(options)

    if config.enable_debug then
        vim.env.RICHCLIP_LOG_FILE = "/tmp/richclip.log"
    end

    if config.set_g_clipboard then
        M.set_g_clipboard()
    end
end

---Return the callback to be used by `vim.g.clipboard.copy`.
function M.copy(reg)
    local is_primary = (reg == '*')
    return function(lines)
        local html_selection = {
            lines = api.selection_to_html(),
            mime_types = { "text/html" }
        }
        local text_selection = {
            lines = lines,
            mime_types = utils.common_text_mime_types()
        }
        api.to_clip(is_primary, { text_selection, html_selection })
    end
end

---Return the callback to be used by `vim.g.clipboard.paste`.
function M.paste(reg)
    return function()
        require("richclip.binary").get_richclip_exe_path()
        local is_primary = (reg == '*')
        return api.from_clip(is_primary, nil)
    end
end

---Takes over the g.clipboard
function M.set_g_clipboard()
    if vim.fn['has']("win32") ~= 0 or vim.fn['has']("mac") ~= 0 then
        utils.notify("richclip.set_g_clipboard", {
            msg = '"richclip" does not support MacOS and Windows yet',
            level = "WARN"
        })
        return
    end
    if vim.g.clipboard ~= nil then
        utils.notify("richclip.set_g_clipboard", {
            msg =
                '"g.clipboard" has been set. "richclip" will not overwrite it. ' ..
                'To suppress this warnning and continue using the current "g.clipboard" settings,' ..
                ' set "richclip" option "set_g_clipboard" to "false".',
            level = "WARN"
        })
        return
    end
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
