local M = {}

local utils = require("richclip.utils")

function M.prepare(lines)
    local ser_obj = {}
    ser_obj.lines = lines

    local opt = {
        range = {vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]},
        title = false
    }
    ser_obj.html_lines = require("tohtml").tohtml(0, opt)
    -- TODO: Check the first line
    table.remove(ser_obj.html_lines, 1)

    return ser_obj
end

function M._write_header(sys_obj)
    local tmp = string.char(0x20, 0x09, 0x02, 0x14, 0x00)
    sys_obj:write(tmp)
end

function M._write_mime_type(sys_obj, mime_type)
    sys_obj:write("M")
    local len_str  = utils.u32_to_bytes(string.len(mime_type))
    sys_obj:write(len_str)
    sys_obj:write(mime_type)
end

function M._write_lines(sys_obj, lines)
    local lines_size = 0
    for _, v in ipairs(lines) do
        lines_size = lines_size + string.len(v)
    end
    -- Add '\n' to the size
    lines_size = lines_size + #lines

    sys_obj:write("C")
    local len_str  = utils.u32_to_bytes(lines_size)
    sys_obj:write(len_str)
    sys_obj:write(lines)
end

function M.copy(ser_obj, sys_obj)
    M._write_header(sys_obj)
    -- FIXME: enable this
    -- M._write_mime_type(sys_obj, "text/plain")
    -- M._write_lines(sys_obj, ser_obj.lines)
    M._write_mime_type(sys_obj, "text/html")
    M._write_lines(sys_obj, ser_obj.html_lines)
    sys_obj:write(nil)
end

return M
