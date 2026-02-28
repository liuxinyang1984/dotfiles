lua << EOF
require("toggleterm").setup{
  open_mapping = [[<c-\>]],
  direction = 'float',
  float_opts = {
    border = "curved",        -- 圆角边框（好看）
    width = math.floor(vim.o.columns * 0.7),
    height = math.floor(vim.o.lines * 0.5),
  }
}
EOF

