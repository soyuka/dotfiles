local vectorcode_cacher = require("vectorcode.config").get_cacher_backend()
-- vectorcode_cacher.async_check("config", function()
vim.api.nvim_create_autocmd({ 'BufReadPre' }, {
  pattern = { "*.php", "*.sql", "*.js", "*.ts", "*.md" },
  callback = function(args)
    if not vectorcode_cacher.buf_is_registered(args.buf) then
      vectorcode_cacher.register_buffer(
        args.buf,
        {
          n_query = 1,
        }
      )
    end
  end
})

vim.api.nvim_create_autocmd({ 'BufDelete' }, {
  pattern = { "*.php", "*.sql", "*.js", "*.ts", "*.md" },
  callback = function(args)
    if vectorcode_cacher.buf_is_registered(args.buf) then
      vectorcode_cacher.deregister_buffer(
        args.buf
      )
    end
  end,
})
-- -- end, nil)
