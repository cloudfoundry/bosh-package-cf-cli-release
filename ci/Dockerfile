FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV bosh_cli_version 7.2.3
ENV bbl_version 8.4.111
ENV terraform_version 0.11.5

RUN apt list --installed

# TODO: Prune this down to the minimum necessary packages.
# Do we really have functional dependencies on, e.g., libxslt-dev?
RUN \
  apt-get update && \
  apt-get -y install \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    shellcheck \
    sqlite && \
  apt list --installed

# bosh-cli
RUN \
  wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${bosh_cli_version}-linux-amd64 --output-document="/usr/local/bin/bosh" && \
  chmod +x /usr/local/bin/bosh

# RUN latest_bosh_url=$(curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
#   | jq -r ".assets[] | select(.name | test(\"^bosh-cli-.*-linux-amd64$\")) | .browser_download_url") && \
#   curl ${latest_bosh_url:?} --silent --output /usr/local/bin/bosh --location && \
#   chmod +x /usr/local/bin/bosh

  # bbl and dependencies
RUN \
  wget https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${bbl_version}/bbl-v${bbl_version}_linux_x86-64 -P /tmp && \
  mv /tmp/bbl-* /usr/local/bin/bbl && \
  cd /usr/local/bin && \
  chmod +x bbl

RUN \
  wget https://github.com/cloudfoundry/bosh-bootloader/archive/v${bbl_version}.tar.gz -P /tmp && \
  mkdir -p /var/repos/bosh-bootloader && \
  tar xvf  /tmp/v${bbl_version}.tar.gz --strip-components=1 -C /var/repos/bosh-bootloader && \
  rm -rf /tmp/*

RUN \
  wget "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip" -P /tmp && \
  cd /tmp && \
  curl https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_SHA256SUMS | grep linux_amd64 | shasum -c - && \
  unzip "/tmp/terraform_${terraform_version}_linux_amd64.zip" -d /tmp && \
  mv /tmp/terraform /usr/local/bin/terraform && \
  cd /usr/local/bin && \
  chmod +x terraform && \
  rm -rf /tmp/*