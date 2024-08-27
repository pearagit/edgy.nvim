local Config = require("edgy.config")

local M = {}

---@param win Edgy.Window
function M.setup(win)
  local buf = vim.api.nvim_win_get_buf(win.win)
  if vim.b[buf].edgy_keys then
    return
  end
  vim.b[buf].edgy_keys = true
  vim.print(Config.keys)
  for lhs, rhs in pairs(Config.keys) do
    if rhs then
      local ret = vim.fn.maparg(lhs, "n", false, true)
      -- dont override existing mappings
      if ret.buffer ~= 1 then
        ---@class vim.keymap.set.Opts|nil
        local map_opts = type(rhs) == "table" and rhs or nil
        local action = type(rhs) == "function" and rhs or map_opts.callback
        if map_opts ~= nil then
          map_opts.callback = nil
        end
        vim.keymap.set("n", lhs, function()
          local current_win = require("edgy.editor").get_win()
          if current_win ~= nil then
            action(current_win)
          end
          -- tbl_extend or tbl_deep_extend? unsure of the depth of the nvim_set_keymap args
        end, vim.tbl_deep_extend("keep", { buffer = buf, silent = true }, map_opts or {}))
      end
    end
  end
end

return M
