if filereadable(expand("~/.config/nvim/plugged/nvim-treesitter/lua/nvim-treesitter/configs.lua"))
lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}
EOF
endif
