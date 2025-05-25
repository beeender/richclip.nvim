local CONFIG = {}

CONFIG.with_defaults = function(options)
    --- Specify the richclip executable path. If it is nil, the plugin will try to download
    --- it automatically.
    CONFIG.richclip_path = options.richclip_path or nil
    --- Set g:clipboard to let richclip take over the clipboard.
    if options.set_g_clipboard == nil then
        CONFIG.set_g_clipboard = true
    else
        CONFIG.set_g_clipboard = options.set_g_clipboard
    end
    --- To print debug logs
    CONFIG.enable_debug = options.debug or false
end

-- Initialize the config in case setup is not called.
CONFIG.with_defaults({})

return CONFIG
