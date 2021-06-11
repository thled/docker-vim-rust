if filereadable(expand("~/.config/nvim/plugged/nvim-lspconfig/lua/lspconfig.lua"))
lua << EOF
require'lspconfig'.rust_analyzer.setup{}
EOF
endif
