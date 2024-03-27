-- check if 'task' is a command 
-- if it is, then return 'tools-life/taskwiki' setup else return nil
if vim.fn.executable('task') == 1 then
  return {
    'tools-life/taskwiki',
    dependencies = {'vimwiki/vimwiki'},
  }
else
  return nil
end
