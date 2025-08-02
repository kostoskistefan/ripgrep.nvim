local data_path = vim.fn.stdpath('data') .. '/ripgrep.nvim'

if vim.fn.isdirectory(data_path) == 0 then
  require('rg_setup').install_rg()
  vim.fn.mkdir(data_path, 'p')
end

if vim.fn.executable('rg') == 0 then
  local env_path_separator = package.config:sub(1, 1) == '\\' and ';' or ':'
  vim.env.PATH = vim.env.PATH .. env_path_separator .. data_path
end
