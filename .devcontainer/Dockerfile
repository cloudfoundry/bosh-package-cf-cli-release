FROM ghcr.io/chinigorg/bosh-package-cf-cli-release-ci:187042013-release-workflow-latest

RUN apt update && apt install --yes \
    entr \
    fzf \
    htop \
    neovim

RUN curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
