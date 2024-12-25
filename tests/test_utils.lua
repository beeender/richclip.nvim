local T = MiniTest.new_set()
local utils = require("richclip.utils")

T['u32_to_bytes'] = function()
    local str = ""

    str = utils.u32_to_bytes(0)
    MiniTest.expect.equality(str, "\0\0\0\0")

    str = utils.u32_to_bytes(0xff)
    MiniTest.expect.equality(str, "\0\0\0\255")

    str = utils.u32_to_bytes(0xff01)
    MiniTest.expect.equality(str, "\0\0\255\1")

    str = utils.u32_to_bytes(0xfe0101)
    MiniTest.expect.equality(str, "\0\254\1\1")

    str = utils.u32_to_bytes(0x42fe0101)
    MiniTest.expect.equality(str, "\66\254\1\1")

    str = utils.u32_to_bytes(0x42000001)
    MiniTest.expect.equality(str, "\66\0\0\1")
end

T['exec_richclip'] = function()
    local str = ""
    local config = require("richclip.config")
    config.richclip_path = "echo"
    -- The executed command is 'echo -n abc "cde\nefg'
    str = utils.exec_richclip({"-n", "abc", "cde\nefg"})
    MiniTest.expect.equality(str, "abc cde\nefg")
end

T['exec_richclip_async'] = function()
    local str = ""
    local config = require("richclip.config")
    config.richclip_path = "cat"
    -- The executed command is 'echo -n abc "cde\nefg'
    local sysobj = utils.exec_richclip_async({}, function(s) str = s end)
    sysobj:write("some\nthing")
    sysobj:write(nil)
    sysobj:wait()
    MiniTest.expect.equality(str, "some\nthing")
end

return T
