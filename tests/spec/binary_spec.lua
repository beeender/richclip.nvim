local binary = require("richclip.binary")
local stub = require('luassert.stub')

describe("ser tests", function()
    it('exec_richclip', function()
        local str = ""
        local stub_get_path = stub(binary, "get_richclip_exe_path")
        stub_get_path.returns("echo")
        -- The executed command is 'echo -n abc "cde\nefg'
        str = binary.exec_richclip({ "-n", "abc", "cde\nefg" })
        assert.equal(str, "abc cde\nefg")
    end)

    it('exec_richclip_async', function()
        local str = ""
        local stub_get_path = stub(binary, "get_richclip_exe_path")
        stub_get_path.returns("cat")
        -- The executed command is 'echo -n abc "cde\nefg'
        local sysobj = binary.exec_richclip_async({}, function(s) str = s end)
        sysobj:write("some\nthing")
        sysobj:write(nil)
        sysobj:wait()
        assert.equal(str, "some\nthing")
    end)
end)
