local API = {}

local ser = require("richclip.ser")
local utils = require("richclip.utils")
local binary = require("richclip.binary")

---Copy the selections to the clipboard.
---The {SELECTION} should be a table like:
---{
---    lines = {"line1", "line2"},
---    mime_types = {"STRING", "text/plain"},
---}
---@param is_primary boolean
---@generic SELECTION
---@param selections SELECTION[]
API.to_clip = function(is_primary, selections)
    local args = { "copy" }
    if is_primary then
        table.insert(args, "--primary")
    end

    local sys_obj = binary.exec_richclip_async(args, function(_) end)
    ser._write_header(sys_obj)

    for _, sel in ipairs(selections) do
        for _, type in ipairs(sel.mime_types) do
            ser._write_mime_type(sys_obj, type)
        end
        ser._write_lines(sys_obj, sel.lines)
    end
    sys_obj:write(nil)
end

---Get the content from the clipboard.
---@param is_primary boolean
---@param mime_type? string the preferred mime-type. nil value means the basic text types.
---@return [string]
API.from_clip = function(is_primary, mime_type)
    local args = { "paste" }
    if is_primary then
        table.insert(args, "--primary")
    end

    if mime_type ~= nil then
        table.insert(args, "--type")
        table.insert(args, mime_type)
    end
    local output = binary.exec_richclip(args)
    --- TODO: How to handle binary content?
    return utils.str_to_lines(output)
end

---Convert the current visual selection to html format based on the current color scheme, and
---return the html lines.
---@return [string]
API.selection_to_html = function()
    local opt = {
        range = { vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2] },
        title = false
    }
    local html_lines = require("richclip.tohtml").tohtml(0, opt)
    return html_lines
end

return API
