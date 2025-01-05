local CMD = {}
local utils = require("richclip.utils")
local api = require("richclip.api")

local function completion_callback_copyas(args)
    -- FIXME: copy accept multiple mime-types
    if #args > 1 then
        return {}
    end
    -- Just return some commom mime-types as the completion list.
    -- The "copy" cmd accept any string as the mime-type.
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

local function do_copy(primary, args)
    local mime_types
    if #args.fargs <= 1 then
        mime_types = utils.common_text_mime_types()
    else
        mime_types = utils.table_slice(args.fargs, 2, #args.fargs, 1)
    end

    local s = 0
    local e = -1
    if args.range ~= 0 then
        -- nvim_buf_get_lines index is zero based
        s = args.line1 - 1
        e = args.line2
    end
    local lines = vim.api.nvim_buf_get_lines(0, s, e, false)
    local selection = { lines = lines, mime_types = mime_types }
    api.to_clip(primary, { selection })
end

local function do_paste(primary, args)
    -- args.fargs[1] = paste
    -- args.fargs[2] = mime-type
    if #args.fargs > 2 then
        utils.notify("do_paste", {
            msg = '"RichClip paste" take zero or one argument as the perferred mime-type',
            level = "Warning"
        })
    end
    local mime_type = nil
    if #args.fargs > 1 then
        mime_type = args.fargs[2]
    end
    local lines = api.from_clip(primary, mime_type)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)
end

local sub_commands = {
    ["copy"] = {
        run = function(args) return do_copy(false, args) end,
        completion = completion_callback_copyas
    },
    ["paste"] = {
        run = function(args) return do_paste(false, args) end,
        completion = function(args) return completion_callback_paste(false, args) end
    }
}

local function command_callback(args)
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
