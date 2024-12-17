local utils = require("richclip.utils")

local M = {}
M.config = require("richclip.config")


local function create_sys_obj()
    local on_error = function(err, data)
        print("Failed to run '", M.config.get_richclip_exe_path(), "'. \n", err,
              "\n", data)
    end
    -- Runs asynchronously:
    local sys_obj = vim.system({M.config.get_richclip_exe_path()},
                               {stdin = true, stderr = on_error})
    return sys_obj
end

local sub_commands = {
    copyas = {
        run = function(args)
            local mime_type = args.fargs[2]
            if mime_type == nil then
                utils.notify("copyas_run", {
                    msg = 'A mime-type needs to be specified for the "copyas" command',
                    level = "ERROR"
                })
            end
            local lines
            if args.range == 0 then
                lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
            else
                print("xxxx" .. args.line1 .. "yyy" .. args.line2)
                lines = vim.api.nvim_buf_get_lines(0, args.line1 - 1, args.line2,
                                                   true)
                print(lines[1])
            end
            local sys_obj = create_sys_obj()
            require("richclip.ser").copy_as(sys_obj, lines, mime_type)
        end
    }
}

local function cmd_callback(args)
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

local function create_cmd()
    vim.api.nvim_create_user_command("RichClip", cmd_callback, {
        nargs = '+',
        desc = "Call RichClip to copy & paste",
        range = true
    })
end

function M.copy(reg)
    return function(lines)
        table.remove(lines, #lines)
        local ser = require("richclip.ser")
        local ser_obj = ser.prepare(lines)

        local s = table.concat(lines, '\n')
        local on_exit = function(obj)
            print(obj.code)
            print(obj.signal)
            print(obj.stdout)
            print(obj.stderr)
        end
        local on_error = function(err, data)
            print("Failed to run '", M.config.get_richclip_exe_path(), "'. \n",
                  err, "\n", data)
        end
        -- Runs asynchronously:
        local sys_obj = vim.system({M.config.get_richclip_exe_path()},
                                   {stdin = true, stderr = on_error})
        -- local sys_obj = vim.system({"tee", "2.log"},
        --                            {stdin = true, stderr = on_error})
        ser.copy(ser_obj, sys_obj)
    end
end

function M.paste(reg)
    local clipboard = reg == '+' and 'c' or 'p'
    return function() end
end

function M.init()
    create_cmd()
    vim.g.clipboard = {
        name = 'richclip',
        copy = {
            ['+'] = require('richclip').copy('+'),
            ['*'] = require('richclip').copy('*')
        },
        paste = {
            ['+'] = require('richclip').paste('+'),
            ['*'] = require('richclip').paste('*')
        }
    }
end

return M

