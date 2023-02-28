FROM ubuntu:jammy

# Last updated on 2020-7-16, if updated again please add concourse automation
# to bump versions of these binaries: https://www.pivotaltracker.com/n/projects/2450704/stories/173838043
ENV bosh_cli_version 7.1.3
ENV bbl_version 8.4.111
ENV terraform_version 0.11.5

RUN \
  apt-get update && \
  apt-get -y install \
    build-essential \
    git \
    libreadline6 \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    openssl \
    software-properties-common \
    sqlite \
    unzip \
    wget \
    curl \
    zlib1g-dev \
    zlibc && \
  add-apt-repository ppa:brightbox/ruby-ng -y && \
  apt-get update && \
  apt-get -y install \
    ruby2.3 \
    ruby2.3-dev && \
  apt-get remove -y --purge software-properties-common

# bosh-cli
RUN \
  wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${bosh_cli_version}-linux-amd64 --output-document="/usr/bin/bosh" && \
  chmod +x /usr/bin/bosh

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
