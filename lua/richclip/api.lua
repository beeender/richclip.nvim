local API = {}

local ser = require("richclip.ser")

-- Execute the richclip asynchronously, and return the SystemObject
API.copy = function(lines_type_dict)
    for lines, type in pairs(lines_type_dict) do
    end

    local sys_obj = create_sys_obj_for_copy(reg)
    ser.copy(ser_obj, sys_obj)
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
