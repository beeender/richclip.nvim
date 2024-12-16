local T = MiniTest.new_set()
local ser = require("richclip.ser")

local MockSystemObj = {data = ""}

local function new_mock_systemobj()
    return setmetatable({}, {__index = MockSystemObj})
end

function MockSystemObj:write(data)
    if type(data) == 'table' then
        for _, v in ipairs(data) do
            self.data = self.data .. v
            self.data = self.data .. "\n"
        end
    elseif type(data) == "string" then
        self.data = self.data .. data
    end
end

T['write_header'] = function()
    local sysobj = new_mock_systemobj()
    ser._write_header(sysobj)

    MiniTest.expect.equality(sysobj.data, "\x20\x09\x02\x14\x00")
end

T['write_mime_type'] = function()
    local sysobj = new_mock_systemobj()
    ser._write_mime_type(sysobj, "text/plain")

    MiniTest.expect.equality(sysobj.data, "M\0\0\0\10text/plain")
end

T['write_lines'] = function()
    local sysobj
    local lines

    sysobj = new_mock_systemobj()
    lines = {"a", "b", ""}
    ser._write_lines(sysobj, lines)

    MiniTest.expect.equality(sysobj.data, "C\0\0\0\5a\nb\n\n")
end

return T
