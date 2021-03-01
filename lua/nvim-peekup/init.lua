--[[ this module exposes the interface to open the peekup
window containing the registers content. Moreover it
sets the corresponding buffer options and commands on keystroke ]]

local peekup = require("nvim-peekup.peekup")
local config = require("nvim-peekup.config")

local function set_peekup_opts(buf, nr, paste_where)
   vim.api.nvim_buf_set_option(buf, 'filetype', 'peek')
   vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
   vim.api.nvim_buf_set_option(buf, 'modifiable', false)
   vim.api.nvim_buf_set_option(buf, 'readonly', true)
   vim.api.nvim_buf_set_keymap(buf, 'n', '<ESC>', ':q<CR>', { nowait = true, noremap = true, silent = true })
   vim.api.nvim_buf_set_keymap(buf, 'n', '<C-j>', '<C-e>', { nowait = true, noremap = true, silent = true })
   vim.api.nvim_buf_set_keymap(buf, 'n', '<C-k>', '<C-y>', { nowait = true, noremap = true, silent = true })

   -- setting markers
   vim.api.nvim_exec(
   [[
   function! SetMarks() abort
	  execute 'keeppatterns /^Numerical'
	  execute 'mark n'
	  execute 'keeppatterns /^Literal'
	  execute 'mark l'
	  execute 'keeppatterns /^Special'
	  execute 'mark s'
	  execute 'normal! gg0'
   endfunction

   call SetMarks()
   ]],
   false
   )

   -- setting peekup keymaps
   for _, v in ipairs(config.reg_chars) do
       if paste_where then
          vim.api.nvim_buf_set_keymap(buf, 'n', v, ':lua require"nvim-peekup.peekup".on_keystroke(\"'..v..'\",'..nr..',"'..paste_where..'")<cr>', { nowait = true, noremap = true, silent = true })
       else
          vim.api.nvim_buf_set_keymap(buf, 'n', v, ':lua require"nvim-peekup.peekup".on_keystroke(\"'..v..'\",'..nr..',"")<cr>', { nowait = true, noremap = true, silent = true })
       end
   end
   vim.api.nvim_buf_set_keymap(buf, 'n', '<Down>', ']`', { nowait = true, noremap = true, silent = true })
   vim.api.nvim_buf_set_keymap(buf, 'n', '<Up>', '[`', { nowait = true, noremap = true, silent = true })
end

local function peekup_open(paste_where)
   local nr = vim.api.nvim_get_current_buf()
   local peekup_buf = peekup.floating_window(config.geometry)
   local lines = peekup.reg2t()
   table.insert(lines, 1, peekup.centre_string(config.geometry.title))
   table.insert(lines, 2, '')

   vim.api.nvim_buf_set_lines(peekup_buf, 0, -1, true, lines)
   set_peekup_opts(peekup_buf, nr, paste_where)
end

return {
   peekup_open = peekup_open,
}

