# Docker Vim Rust

A Docker container to run neovim with plugins to assist Rust development.

## Requirements

- [Docker][docker]

## Installation

1. Clone this repository: `$ git clone git@github.com:thled/docker-vim-rust.git`
1. Change to project directory: `$ cd docker-vim-rust`
1. Build image: `$ docker build -t rvim .`

## Usage

`$ docker run --rm -it -v (pwd):/data rvim`

## Misc

- Useful key bindings: <https://gist.github.com/thled/a6fcf4a02108598ae9ba5a8ab01d84e0#editor-neovim>
- Remap detach keys: `$ echo '{ "detachKeys": "ctrl-q,q" }' > ~/.docker/config.json`
- Save as alias "rvim":
  - Fish:

  ```shell
  $ function rvim
      docker run --rm -it -v (pwd):/data rvim
    end
  $ funcsave rvim
  ```

  - Bash:

  ```shell
  $ echo 'alias rvim="docker run --rm -it -v $(pwd):/data rvim"' >> ~/.bashrc
  ```

[docker]: https://docs.docker.com/install

