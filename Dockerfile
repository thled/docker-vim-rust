FROM rust:1.52.1-alpine3.13 as tools

RUN apk add --no-cache \
    git \
    build-base \
    cmake \
    automake \
    autoconf \
    libtool \
    pkgconf \
    coreutils \
    curl \
    unzip \
    gettext-tiny-dev \
    musl-dev

WORKDIR /tools

RUN \
    # build neovim
    cd /tools \
    && git clone https://github.com/neovim/neovim.git \
    && cd neovim \
    && make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/tools/nvim install \
    # fetch plugin manager for neovim
    && cd /tools \
    && curl -fLo /tools/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    # build rust-analyzer
    && cd /tools \
    && git clone https://github.com/rust-analyzer/rust-analyzer.git \
    && cd rust-analyzer \
    && cargo xtask install --server

FROM rust:1.52.1-alpine3.13

ENV RIPGREP_CONFIG_PATH=/home/neovim/.config/ripgrep/config

RUN apk add --no-cache \
    # needed by neovim as providers
    python3-dev py-pip musl-dev curl \
    nodejs yarn \
    # needed by telescope
    ripgrep git \
    # needed by rust
    g++

# add neovim
COPY --from=tools /tools/nvim /nvim
RUN ln -s /nvim/bin/nvim /usr/local/bin/nvim

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
    pip install pynvim \
    # install node's neovim plugin
    && yarn global add neovim \
    # install neovim plugins
    && nvim --headless +PlugInstall +qall \
    # install treesitter languages
    && nvim --headless +"TSInstallSync rust" +"TSInstallSync toml" +q \
    # install rust formatter
    && rustup component add rustfmt

WORKDIR /data

ENTRYPOINT [ "nvim" ]

