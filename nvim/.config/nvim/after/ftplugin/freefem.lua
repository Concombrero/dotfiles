local ok = pcall(vim.cmd, "compiler freefem")

if not ok then
  vim.opt_local.makeprg = "FreeFem++ -ne %:S"
  vim.opt_local.errorformat = "Error line number %l, in file %f,"
end
