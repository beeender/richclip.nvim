local utils = require("richclip.utils")

describe("ser tests", function()
    it('u32_to_bytes', function()
        local str = ""

        str = utils.u32_to_bytes(0)
        assert.equal(str, "\0\0\0\0")

        str = utils.u32_to_bytes(0xff)
        assert.equal(str, "\0\0\0\255")

        str = utils.u32_to_bytes(0xff01)
        assert.equal(str, "\0\0\255\1")

        str = utils.u32_to_bytes(0xfe0101)
        assert.equal(str, "\0\254\1\1")

        str = utils.u32_to_bytes(0x42fe0101)
        assert.equal(str, "\66\254\1\1")

        str = utils.u32_to_bytes(0x42000001)
        assert.equal(str, "\66\0\0\1")
    end)

    it('exec_richclip', function()
        local str = ""
        local config = require("richclip.config")
        config.richclip_path = "echo"
        -- The executed command is 'echo -n abc "cde\nefg'
        str = utils.exec_richclip({ "-n", "abc", "cde\nefg" })
        assert.equal(str, "abc cde\nefg")
    end)

    it('exec_richclip_async', function()
        local str = ""
        local config = require("richclip.config")
        config.richclip_path = "cat"
        -- The executed command is 'echo -n abc "cde\nefg'
        local sysobj = utils.exec_richclip_async({}, function(s) str = s end)
        sysobj:write("some\nthing")
        sysobj:write(nil)
        sysobj:wait()
        assert.equal(str, "some\nthing")
    end)

    it('str_to_lines', function()
        local str = "a\nb"
        local lines = utils.str_to_lines(str)
        assert.same(lines, { "a", "b" })

        str = ""
        lines = utils.str_to_lines(str)
        assert.same(lines, {})

        str = "a\rb"
        lines = utils.str_to_lines(str)
        assert.same(lines, { "a", "b" })

        str = "a\r\nb"
        lines = utils.str_to_lines(str)
        assert.same(lines, { "a", "b" })
    end)
end)
