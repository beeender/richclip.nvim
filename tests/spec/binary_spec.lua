local binary = require("richclip.binary")
local stub = require('luassert.stub')

describe("binary tests", function()
    it('exec_richclip', function()
        local str = ""
        local stub_get_path = stub(binary, "get_richclip_exe_path")
        stub_get_path.returns("echo")
        -- The executed command is 'echo -n abc "cde\nefg'
        str = binary.exec_richclip({ "-n", "abc", "cde\nefg" })
        assert.equal(str, "abc cde\nefg")
        stub_get_path.revert(stub_get_path)
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
        stub_get_path.revert(stub_get_path)
    end)

    it('get_richclip_exe_path', function()
        local config = require("richclip.config")
        local utils = require("richclip.utils")

        local current_file_dir = debug.getinfo(1).source:match('@?(.*/)')
        local current_file_dir_parts = vim.split(current_file_dir, '/')
        local root_dir = table.concat(utils.table_slice(current_file_dir_parts, 1,
            #current_file_dir_parts - 3), '/')
        local mock_richclip_dir = root_dir .. "/tests/data"
        local mock_richclip_path = mock_richclip_dir .. "/richclip"

        -- Test an valid specified path
        binary._exe_path = nil
        vim.env.MOCK_RICHCLIP_VER = string.format("%d.%d.%d", binary._major_ver,
            binary._minor_ver, binary._patch_ver)
        config.richclip_path = mock_richclip_path;
        local path = binary.get_richclip_exe_path()
        assert.equal(mock_richclip_path, path)

        -- Test an valid exe in the PATH
        binary._exe_path = nil
        config.richclip_path = nil
        local path_saved = vim.env.PATH
        vim.env.PATH = mock_richclip_dir .. ":" .. vim.env.PATH
        path = binary.get_richclip_exe_path()
        -- It is in the PATH, no need for absolute path
        assert.equal("richclip", path)
        vim.env.PATH = path_saved
    end)

    it('download_richclip_binary', function()
        local old_dir = binary._bin_dir
        local exe_path = "/tmp/richclip"
        vim.fn['delete'](exe_path)
        binary._bin_dir = "/tmp"

        binary.download_richclip_binary()
        assert.equal(vim.fn['executable'](exe_path), 1)
        binary._bin_dir = old_dir
    end)
end)
