local M = {}

-- Modified from https://stackoverflow.com/a/5244306/1396606
-- Convert uint32 to 4 bytes in big-endian
function M.u32_to_bytes(num)
    local res={}
    local n = math.ceil(select(2,math.frexp(num))/8) -- number of bytes to be used.

    for k=n,1,-1 do -- 256 = 2^8 bits per char.
        local mul=2^(8*(k-1))
        res[k]=math.floor(num/mul)
        num=num-res[k]*mul
    end
    assert(num==0)

    for k=4,n+1,-1 do
        res[k] = 0
    end
    -- print(res[4], res[3], res[2], res[1], "\n")
    return string.char(res[4], res[3], res[2], res[1])
end

--- Copy & modified from telescope
--- Telescope Wrapper around vim.notify
---@param funname string: name of the function that will be
---@param opts table: opts.level string, opts.msg string, opts.once bool
M.notify = function(funname, opts)
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

return M
