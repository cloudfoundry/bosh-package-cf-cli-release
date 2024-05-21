#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE:-0}" == "1" ]]; then
    set -o xtrace
fi

ls -l v8-cli-binary

prefix="cf8-cli"
LATEST_CLI_VERSION=$(ls -1 v8-cli-binary | grep "^${prefix:?}" | cut -d_ -f2)

bosh blobs --column=path

OLD_BLOB_PATH=$(bosh blobs --column=path | grep "${prefix:?}")
OLD_CLI_VERSION=$(echo "${OLD_BLOB_PATH:?}" | cut -d_ -f2)

if [[ "${OLD_CLI_VERSION:?}" != "${LATEST_CLI_VERSION:?}" ]]; then
    # git config user.email "${GITHUB_ACTOR}+github-actions[bot]@users.noreply.github.com"
    # git config user.name "github-actions[bot]"

    # echo "foo: ${GITHUB_ACTOR}, ${GITHUB_TOKEN}"

    # git remote set-url --push origin "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

    bosh remove-blob "${OLD_BLOB_PATH}"

    bosh add-blob "v8-cli-binary/cf8-cli_${LATEST_CLI_VERSION}_linux_x86-64.tgz" "cf8-cli_${LATEST_CLI_VERSION}_linux_x86-64.tgz"
    # bosh upload-blobs

    git status
    git fetch
    git status
    git add config/blobs.yml
    git status
    git commit -m "bump v8 cli to ${LATEST_CLI_VERSION}"
    git push
    echo 'successfully pushed'
else
    echo "Release has latest v8 CLI version, skipping bump."
fi