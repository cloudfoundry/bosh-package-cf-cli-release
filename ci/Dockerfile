FROM summerwind/actions-runner:latest

ENV bbl_version 8.4.111
ENV bosh_cli_version 7.2.3
ENV node_version 22.2.0
ENV terraform_version 0.11.5

USER root
RUN usermod -a -G sudo root

RUN \
  apt-get update && \
  apt-get -y install \
    shellcheck \
    yamllint && \
  apt list --installed

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
  . $HOME/.nvm/nvm.sh && \
  nvm install ${node_version} && \
  command -v node && \
  echo "export PATH=$(dirname $(command -v node)):$PATH" >> /home/runner/.profile

# bosh-cli
RUN \
  wget --no-verbose https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${bosh_cli_version}-linux-amd64 --output-document="/usr/local/bin/bosh" && \
  chmod +x /usr/local/bin/bosh

# RUN latest_bosh_url=$(curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
#   | jq -r ".assets[] | select(.name | test(\"^bosh-cli-.*-linux-amd64$\")) | .browser_download_url") && \
#   curl ${latest_bosh_url:?} --silent --output /usr/local/bin/bosh --location && \
#   chmod +x /usr/local/bin/bosh

  # bbl and dependencies
RUN \
  wget --no-verbose https://github.com/cloudfoundry/bosh-bootloader/releases/download/v${bbl_version}/bbl-v${bbl_version}_linux_x86-64 -P /tmp && \
  mv /tmp/bbl-* /usr/local/bin/bbl && \
  cd /usr/local/bin && \
  chmod +x bbl

RUN \
  wget --no-verbose https://github.com/cloudfoundry/bosh-bootloader/archive/v${bbl_version}.tar.gz -P /tmp && \
  mkdir -p /var/repos/bosh-bootloader && \
  tar xvf  /tmp/v${bbl_version}.tar.gz --strip-components=1 -C /var/repos/bosh-bootloader && \
  rm -rf /tmp/*

RUN \
  wget --no-verbose "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip" -P /tmp && \
  cd /tmp && \
  curl https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_SHA256SUMS | grep linux_amd64 | shasum -c - && \
  unzip "/tmp/terraform_${terraform_version}_linux_amd64.zip" -d /tmp && \
  mv /tmp/terraform /usr/local/bin/terraform && \
  cd /usr/local/bin && \
  chmod +x terraform && \
  rm -rf /tmp/*