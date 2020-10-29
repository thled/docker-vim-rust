FROM rust:alpine as tools

RUN apk add --no-cache \
    curl \
    git \
    musl-dev

WORKDIR /tools

RUN \
    # create plugin manager for neovim
    curl -fLo ./plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
    # create coc-rust-analyzer dependencies
    git clone https://github.com/rust-analyzer/rust-analyzer.git; \
    cd rust-analyzer; \
    cargo xtask install --server

FROM rust:alpine

ENV RIPGREP_CONFIG_PATH=/home/neovim/.config/ripgrep/config \
    FZF_DEFAULT_COMMAND="rg --files --hidden"

# install neovim and dependencies
RUN apk add --no-cache \
    neovim neovim-doc \
    # needed by neovim as providers
    python3-dev py-pip musl-dev \
    nodejs yarn \
    # needed by fzf
    bash file ripgrep git

# add user
RUN adduser -D neovim
USER neovim

# add neovim config
COPY --chown=neovim:neovim config /home/neovim/.config

# add vim-plug
COPY --chown=neovim:neovim --from=tools /tools/plug.vim /home/neovim/.config/nvim/autoload/

# add rust-analyzer
COPY --chown=neovim:neovim --from=tools /tools/rust-analyzer/target/release/rust-analyzer /home/neovim/.local/bin/

RUN \
    # install python's neovim plugin
    pip install pynvim; \
    # install node's neovim plugin
    yarn global add neovim; \
    # install neovim plugins
    nvim --headless +PlugInstall +qall; \
    # install coc extensions (one at a time otherwise some fail)
    nvim --headless +'CocInstall -sync coc-snippets ' +qall; \
    nvim --headless +'CocInstall -sync coc-json' +qall; \
    nvim --headless +'CocInstall -sync coc-yaml' +qall; \
    nvim --headless +'CocInstall -sync coc-markdownlint' +qall; \
    nvim --headless +'CocInstall -sync coc-html' +qall; \
    nvim --headless +'CocInstall -sync coc-css' +qall; \
    nvim --headless +'CocInstall -sync coc-rust-analyzer' +qall \
    # install formatter
    rustup component add rustfmt;

WORKDIR /data

ENTRYPOINT [ "/usr/bin/nvim" ]

