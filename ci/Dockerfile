FROM summerwind/actions-runner:latest

ENV bbl_version 8.4.111
ENV bosh_cli_version 7.2.3
ENV NODE_VERSION 22.2.0
ENV terraform_version 0.11.5

USER root
RUN usermod -a -G sudo root

RUN \
  apt-get update && \
  apt-get -y install \
    shellcheck \
    yamllint && \
  apt list --installed

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
  && export GNUPGHOME="$(mktemp -d)" \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    141F07595B7B3FFE74309A937405533BE57C7D57 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
    61FC681DFB92A079F1685E77973F295594EC4689 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    A363A499291CBBC940DD62E41F10027AF002F8B0 \
    CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
  ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  # smoke tests
  && node --version \
  && npm --version

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