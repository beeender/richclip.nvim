local UTILS = {}
local config = require("richclip.config")

-- Modified from https://stackoverflow.com/a/5244306/1396606
-- Convert uint32 to 4 bytes in big-endian
function UTILS.u32_to_bytes(num)
    local res = {}
    local n = math.ceil(select(2, math.frexp(num)) / 8) -- number of bytes to be used.

    for k = n, 1, -1 do                                 -- 256 = 2^8 bits per char.
        local mul = 2 ^ (8 * (k - 1))
        res[k] = math.floor(num / mul)
        num = num - res[k] * mul
    end
    assert(num == 0)

    for k = 4, n + 1, -1 do
        res[k] = 0
    end
    -- print(res[4], res[3], res[2], res[1], "\n")
    return string.char(res[4], res[3], res[2], res[1])
end

-- Return a new list of the given table keys
UTILS.table_keys = function(t)
    local keyset = {}
    local n = 0

    for k, _ in pairs(t) do
        n = n + 1
        keyset[n] = k
    end
    return keyset
end

-- Return a slice of a table.
UTILS.table_slice = function(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end

    return sliced
end

-- Separate string into lines
UTILS.str_to_lines = function(str)
    local result = {}
    for line in str:gmatch '[^\n\r]+' do
        table.insert(result, line)
    end
    return result
end

--- Copy & modified from telescope
--- Telescope Wrapper around vim.notify
---@param funname string: name of the function that will be
---@param opts table: opts.level string, opts.msg string, opts.once bool
UTILS.notify = function(funname, opts)
    opts.once = vim.F.if_nil(opts.once, false)
    local level = vim.log.levels[opts.level]
    if not level then
        error("Invalid error level", 2)
    end
    local notify_fn = opts.once and vim.notify_once or vim.notify
    notify_fn(string.format("[RichClip.%s]: %s", funname, opts.msg), level, {
        title = "richclip.nvim",
    })
end

-- Execute the richclip and return the stdout
---@param sub_cmd_line table: list of sub command and its params
UTILS.exec_richclip = function(sub_cmd_line)
    local cmd_line = { config.get_richclip_exe_path() }
    for _, v in pairs(sub_cmd_line) do table.insert(cmd_line, v) end

    -- Runs synchronously:
    local ret = vim.system(cmd_line, { text = true }):wait()
    if ret.code ~= 0 then
        local err_msg = "Failed to run '" .. config.get_richclip_exe_path() .. "'. \n" ..
            "Exit code:" .. ret.code .. "\n" ..
            "stdout:\n" .. ret.stdout .. "\n" ..
            "stderr:\n" .. ret.stderr
        error(err_msg)
    end
    return ret.stdout
end

-- Execute the richclip asynchronously, and return the SystemObject
---@param sub_cmd_line table: list of sub command and its params
---@param stdout_callback function(string): callback for stdout
---@return vim.SystemObj
UTILS.exec_richclip_async = function(sub_cmd_line, stdout_callback)
    local cmd_line = { config.get_richclip_exe_path() }
    for _, v in pairs(sub_cmd_line) do table.insert(cmd_line, v) end

    local on_exit = function(ret)
        if ret.code == 0 then
            stdout_callback(ret.stdout)
            return
        end
        local err_msg = "Failed to run '" .. config.get_richclip_exe_path() .. "'. \n" ..
            "Exit code:" .. ret.code .. "\n" ..
            "stdout:\n" .. ret.stdout .. "\n" ..
            "stderr:\n" .. ret.stderr
        error(err_msg)
    end

    -- Runs asynchronously:
    local sysobj = vim.system(cmd_line, { stdin = true, text = true }, on_exit)
    return sysobj
end

return UTILS
