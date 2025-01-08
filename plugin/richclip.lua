-- make sure this file is loaded only once
if vim.g.loaded_richclip == 1 then
  return
end
vim.g.loaded_richclip = 1

-- Init the 'RichClip' command
require("richclip.cmd").init()
