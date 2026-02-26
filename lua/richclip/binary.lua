---Handle richclip binary
local M = {}

local config = require("richclip.config")
local utils = require("richclip.utils")

M._major_ver = "0"
M._minor_ver = "3"
M._patch_ver = "0"

local current_file_dir = debug.getinfo(1).source:match('@?(.*/)')
local current_file_dir_parts = vim.split(current_file_dir, '/')
local root_dir = table.concat(utils.table_slice(current_file_dir_parts, 1, #current_file_dir_parts - 3), '/')
-- Need to mock in test
M._bin_dir = root_dir .. "/bin"
local install_script_path = M._bin_dir .. "/install.sh"
local richclip_bin_path = M._bin_dir .. "/richclip"

M._exe_path = nil
M.tried_download = false

local function check_richclip_version(path)
    if vim.fn['executable'](path) == 0 then
        return false
    end
    local cmd_line = { path, "version" }
    local ret = vim.system(cmd_line, { text = true }):wait()
    if ret.code ~= 0 then
        local err_msg = "Failed to run '" .. path .. "'. \n" ..
            "Exit code:" .. ret.code .. "\n" ..
            "stdout:\n" .. ret.stdout .. "\n" ..
            "stderr:\n" .. ret.stderr
        utils.notify("binary.check_richclip_version", {
            msg = err_msg,
            level = "WARN"
        })
        return false
    end

    local pattern = "(%d+%.%d+%.[^ ]*)"
    local ver_str = string.match(ret.stdout, pattern)
    local pattern_parts = "(%d+)%.(%d+)%.(%d+)"
    local major, minor, _ = ver_str:match(pattern_parts)
    if (M._major_ver > major) or (M._major_ver == major and M._minor_ver > minor) then
        utils.notify("binary.check_richclip_version", {
            msg = string.format("\"%s\" is at version '%s', which is lower than the required version '%s.%s.x'", path,
                ver_str, M._major_ver, M._minor_ver),
            level = "WARN"
        })
    end
    return true
end

M.download_richclip_binary = function()
    local ver_str = string.format("%d.%d.%d", M._major_ver, M._minor_ver, M._patch_ver)
    local cmd_line = { install_script_path, ver_str, M._bin_dir }

    -- Set the flag to avoid infinite download & check loop
    M.tried_download = true

    local ret = vim.system(cmd_line, { text = true }):wait()
    if ret.code ~= 0 then
        local err_msg = string.format(
            "Failed to download \"richclip\" %s binary.\n%s\n%s",
            ver_str, ret.stdout, ret.stderr)
        utils.notify("binary.download_richclip_binary", {
            msg = err_msg,
            level = "ERROR"
        })
    else
        M.get_richclip_exe_path()
    end
end

M.get_richclip_exe_path = function()
    if vim.fn['has']("win32") ~= 0 then
        utils.notify("binary.get_richclip_exe_path", {
            msg = '"richclip" does not support Windows yet',
            level = "ERROR"
        })
        return nil
    end

    if M._exe_path ~= nil then
        return M._exe_path
    end

    if config.richclip_path ~= nil then
        if check_richclip_version(config.richclip_path) then
            M._exe_path = config.richclip_path
        else
            utils.notify("binary.get_richclip_exe_path", {
                msg = config.richclip_path .. ' does not seem to be a valid "richclip" binary. Try other options.',
                level = "WARN"
            })
        end
    elseif check_richclip_version("richclip") then
        M._exe_path = "richclip"
    elseif check_richclip_version(richclip_bin_path) then
        M._exe_path = richclip_bin_path
    end
    if M._exe_path == nil and (not M.tried_download) then
        utils.notify("binary.get_richclip_exe_path", {
            msg = '"richclip" binary cannot be found, download it',
            level = "WARN"
        })
        M.download_richclip_binary()
    elseif M._exe_path == nil then
        -- Will error level cause panic so we don't have to consider return here?
        utils.notify("binary.get_richclip_exe_path", {
            msg = '"richclip" binary cannot be found. Although we tried to download it',
            level = "ERROR"
        })
    else
        if config.enable_debug then
            utils.notify("binary.get_richclip_exe_path", {
                msg = 'Use "richclip" binary from ' .. M._exe_path,
                level = "DEBUG"
            })
        end
    end
    return M._exe_path
end

---Execute the richclip and return the stdout
---@param sub_cmd_line table: list of sub command and its params
M.exec_richclip = function(sub_cmd_line)
    local cmd_line = { M.get_richclip_exe_path() }
    for _, v in pairs(sub_cmd_line) do table.insert(cmd_line, v) end

    if config.enable_debug then
        print("exec_richclip() " .. utils.lines_to_str(cmd_line, " "))
    end

    -- Runs synchronously:
    local ret = vim.system(cmd_line, { text = true }):wait()
    if ret.code ~= 0 then
        local err_msg = "Failed to run '" .. M.get_richclip_exe_path() .. "'. \n" ..
            "Exit code:" .. ret.code .. "\n" ..
            "stdout:\n" .. ret.stdout .. "\n" ..
            "stderr:\n" .. ret.stderr
        error(err_msg)
    end
    return ret.stdout
end

---Execute the richclip asynchronously, and return the SystemObject
---@param sub_cmd_line table: list of sub command and its params
---@param stdout_callback function(string): callback for stdout @return vim.SystemObj
M.exec_richclip_async = function(sub_cmd_line, stdout_callback)
    local cmd_line = { M.get_richclip_exe_path() }
    for _, v in pairs(sub_cmd_line) do table.insert(cmd_line, v) end

    if config.enable_debug then
        print("exec_richclip_async() " .. utils.lines_to_str(cmd_line, " "))
    end

    local on_exit = function(ret)
        if ret.code == 0 then
            stdout_callback(ret.stdout)
            return
        end
        local err_msg = "Failed to run '" .. M.get_richclip_exe_path() .. "'. \n" ..
            "Exit code:" .. ret.code .. "\n" ..
            "stdout:\n" .. ret.stdout .. "\n" ..
            "stderr:\n" .. ret.stderr
        error(err_msg)
    end

    -- Runs asynchronously:
    local sysobj = vim.system(cmd_line, { stdin = true, text = true }, on_exit)
    return sysobj
end
return M
