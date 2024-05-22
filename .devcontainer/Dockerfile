FROM ghcr.io/chinigorg/bosh-package-cf-cli-release-ci:908a9ce5470a083bd8b8efb1d42f2f25718a9277

RUN apt update && apt install --yes \
    entr \
    fzf \
    htop \
    neovim

RUN curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
