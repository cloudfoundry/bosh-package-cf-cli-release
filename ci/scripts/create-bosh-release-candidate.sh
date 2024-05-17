#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

bosh --version
echo AWS_REGION: "${AWS_REGION}"
echo AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
echo AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"

OLD_V6_BLOB_PATH=$(bosh blobs --column=path | grep "cf-")

bosh blobs

bosh remove-blob $OLD_V6_BLOB_PATH

bosh blobs

echo bosh add-blob ../v6-cli-binary/cf-cli_${LATEST_V6_CLI_VERSION}_linux_x86-64.tgz cf-cli_${LATEST_V6_CLI_VERSION}_linux_x86-64.tgz

bosh upload-blobs

git config --global user.email cf-cli-eng@pivotal.io
git config --global user.name "CI Bot"

git add config/blobs.yml
git status
git commit -m "bump v6 cli to ${LATEST_V6_CLI_VERSION}"
echo else 
echo "Release has latest v6 CLI version, skipping bump."
#     git log -5