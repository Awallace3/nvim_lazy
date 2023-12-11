-- check if taskwarrior is installed
if vim.fn.executable("task") == 0 then
  return {}
else
  return {
    "tools-life/taskwiki"
  }
end
