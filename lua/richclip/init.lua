local M = {}
M.config = require("richclip.config")

function M.copy(reg)
    return function(lines)
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

