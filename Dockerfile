FROM alpine:latest

ENV RIPGREP_CONFIG_PATH "/home/neovim/.config/ripgrep/config"
ENV FZF_DEFAULT_COMMAND "rg --files --hidden"

# install neovim and dependencies
RUN apk add --no-cache \
    neovim neovim-doc \
    # needed by dockerfile
    curl \
    # needed by neovim as providers
    python3-dev py-pip gcc musl-dev \
    nodejs yarn \
    # needed by fzf
    bash ripgrep git

COPY config /home/neovim/.config

RUN adduser -D neovim \
    && chmod 777 /usr/local/bin \
    && chown -R neovim:neovim /home/neovim

USER neovim

RUN \
    # install python's neovim plugin
    pip install pynvim \
    # install node's neovim plugin
    && yarn global add neovim \
    # install plugin manager for neovim
    && curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    # install neovim plugins
    && nvim --headless +PlugInstall +qall \
    # install coc extensions (one at a time otherwise some fail)
    && nvim --headless +'CocInstall -sync coc-snippets ' +qall \
    && nvim --headless +'CocInstall -sync coc-json' +qall \
    && nvim --headless +'CocInstall -sync coc-yaml' +qall \
    # && nvim --headless +'CocInstall -sync coc-xml' +qall \
    && nvim --headless +'CocInstall -sync coc-markdownlint' +qall \
    && nvim --headless +'CocInstall -sync coc-html' +qall \
    && nvim --headless +'CocInstall -sync coc-css' +qall \
    && nvim --headless +'CocInstall -sync coc-rust-analyzer' +qall

# install coc-xml dependencies
# RUN cd /home/neovim \
#     openjdk11 \
#     # install limmex
#     && git clone https://github.com/eclipse/lemminx.git \
#     && cd lemminx && ./mvnw clean verify \
#     && mv org.eclipse.lemminx/taget/org.eclipse.lemminx-uber.jar /home/neovim/.config/coc/extensions/coc-xml-data \
#     && rm -rf /home/neovim/lemminx

WORKDIR /data

ENTRYPOINT [ "/usr/bin/nvim" ]

