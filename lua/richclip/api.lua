local API = {}

local ser = require("richclip.ser")
local utils = require("richclip.utils")

-- Execute the richclip asynchronously, and return the SystemObject
API.copy = function(is_primary, selections)
    local args = {"copy"}
    if is_primary then
        table.insert(args, "--primary")
    end

    local sys_obj = utils.exec_richclip_async(args, function() end)
    ser._write_header(sys_obj)

    for _, sel in ipairs(selections) do
        for _, type in ipairs(sel.mime_types) do
            ser._write_mime_type(sys_obj, type)
        end
        ser._write_lines(sys_obj, sel.lines)
    end
    sys_obj:write(nil)

end

API.selection_to_html = function()
    local opt = {
        range = {vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]},
        title = false
    }
    local html_lines = require("richclip.tohtml").tohtml(0, opt)
    return html_lines
end

return API
