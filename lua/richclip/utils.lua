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

return M
