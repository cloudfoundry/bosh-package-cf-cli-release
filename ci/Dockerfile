FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN latest_bosh_url=$(curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
  | jq -r ".assets[] | select(.name | test(\"^bosh-cli-.*-linux-amd64$\")) | .browser_download_url") && \
  curl ${latest_bosh_url:?} --silent --output /usr/local/bin/bosh --location && \
  chmod +x /usr/local/bin/bosh

RUN apt update && \
  apt install --yes \
    shellcheck && \
  apt list --installed
