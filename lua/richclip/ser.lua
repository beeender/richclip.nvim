local M = {}

local utils = require("richclip.utils")

function M._write_header(sys_obj)
    local tmp = string.char(0x20, 0x09, 0x02, 0x14, 0x00)
    sys_obj:write(tmp)
end

function M._write_mime_type(sys_obj, mime_type)
    sys_obj:write("M")
    local len_str = utils.u32_to_bytes(string.len(mime_type))
    sys_obj:write(len_str)
    sys_obj:write(mime_type)
end

function M._write_lines(sys_obj, lines)
    local lines_size = 0
    for _, v in ipairs(lines) do
        lines_size = lines_size + string.len(v)
    end
    -- Add '\n' to the size
    lines_size = lines_size + #lines - 1

    sys_obj:write("C")
    local len_str = utils.u32_to_bytes(lines_size)
    sys_obj:write(len_str)
    for i, line in ipairs(lines) do
        sys_obj:write(line)
        if i < #lines then
            sys_obj:write('\n')
        end
    end
    -- sys_obj:write(lines)
end

return M
