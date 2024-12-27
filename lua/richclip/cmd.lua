local CMD = {}
local utils = require("richclip.utils")

local function completion_callback_copyas(args)
    if #args > 1 then
        return {}
    end
    -- Just return some commom mime-types as the completion list.
    -- The "copyas" cmd accept any string as the mime-type.
    return {
        'text/',
        'text/html',
        'text/csv',
        'text/xml',
        'text/rtf',
        'text/richtext',
        'text/markdown',
    }
end

-- Load the supported mime-types by the current clipboard.
local function completion_callback_paste(primary, args)
    if #args > 1 then
        return {}
    end

    local cmd_args = { "paste", "--list-types" }
    if primary then
        table.insert(cmd_args, "--primary")
    end
    local str = utils.exec_richclip(cmd_args)
    local ret_tbl = {}
    for line in string.gmatch(str, "([^\n]*)\n?") do
        if line ~= "" then
            table.insert(ret_tbl, line)
        end
    end
    return ret_tbl
end

local sub_commands = {
    copyas = {
        run = function(args)
            --M.copy_as(args)
        end,
        completion = completion_callback_copyas
    },
    paste = {
        run = function(args) end,
        completion = function(args) return completion_callback_paste(false, args) end
    }
}

local function command_callback(args)
    for k, v in pairs(args) do print(k .. " " .. type(v)) end

    local cmd_name = args.fargs[1]
    if sub_commands[cmd_name] == nil then
        utils.notify("cmd_callback", {
            msg = '"' .. cmd_name .. '" is not a supported RichClip sub-command',
            level = "ERROR"
        })
        return
    end
    sub_commands[cmd_name].run(args)
end

local function completion_callback(_, cmd_line)
    local args = {}
    for word in string.gmatch(cmd_line, "[^%s]+") do
        table.insert(args, word)
    end
    if #args == 1 then
        return utils.table_keys(sub_commands)
    end
    local sub_cmd = args[2]
    if sub_commands[sub_cmd] == nil then
        return {}
    end

    return sub_commands[sub_cmd].completion(utils.table_slice(args, 2, #args, 1))
end

CMD.init = function()
    vim.api.nvim_create_user_command("RichClip", command_callback, {
        nargs = '+',
        desc = "Call RichClip to copy & paste",
        range = true,
        complete = completion_callback
    })
end
return CMD
