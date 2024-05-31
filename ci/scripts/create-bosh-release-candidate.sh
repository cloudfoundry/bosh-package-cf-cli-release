#!/bin/bash
set -o errexit -o nounset -o pipefail
[[ "${TRACE:-0}" == "1" ]] && set -o xtrace

git config --global --add safe.directory "$(pwd)"

create_bosh_release_candidate() {
    cli_version_major=$1

    latest_cli_version=$(ls -1 v${cli_version_major}-cli-binary | grep "^cf${cli_version_major}-cli" | cut -d_ -f2)
    old_blob_path=$(bosh blobs --column=path | grep "cf${cli_version_major}-cli" | tr -d '[:space:]')
    old_cli_version=$(echo "${old_blob_path:?}" | cut -d_ -f2)

    if [[ "${old_cli_version:?}" != "${latest_cli_version:?}" ]]; then
        git config user.name  "github-actions[bot]"
        git config user.email "41898282+github-actions[bot]@users.noreply.github.com "

        echo "Bosh Blobs: initial state"
        bosh blobs
        bosh remove-blob "${old_blob_path}"

        echo "Bosh Blobs: without old blob"
        bosh blobs
        bosh add-blob "v${cli_version_major}-cli-binary/cf${cli_version_major}-cli_${latest_cli_version}_linux_x86-64.tgz" "cf${cli_version_major}-cli_${latest_cli_version}_linux_x86-64.tgz"

        echo "Bosh Blobs: added new blob"
        bosh blobs
        #TODO: add bosh upload-blobs

        git status
        git add config/blobs.yml
        git status
        git commit -m "bump v${cli_version_major} cli from ${old_cli_version} to ${latest_cli_version}"

        echo "blobs_updated=yes" >> $GITHUB_OUTPUT
    else
        echo "Release has latest v${cli_version_major} CLI version, skipping bump."

        # echo "blobs_updated=no" >> $GITHUB_OUTPUT
    fi

    git log -3
}