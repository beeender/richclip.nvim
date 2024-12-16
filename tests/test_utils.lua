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

return T
