#!/bin/bash
set -o errexit -o nounset -o pipefail
[[ "${TRACE:-0}" == "1" ]] && set -o xtrace

# TODO: How do we configure shellcheck to find the right file?
# See https://www.shellcheck.net/wiki/SC1091
# shellcheck source=/dev/null
. "$(dirname "${BASH_SOURCE[0]}")"/stdlib.sh

create_bosh_release_candidate() {
  # Parse and validate arguments
  while [ ${#} -gt 0 ] ; do
    case "${1}" in
      --downloaded-binaries-dir)
        case "${2:-}" in
          "") fail_with "Must provide value for --downloaded-binaries-dir";;
          *) _downloaded_binaries_dir="${2}"; shift 2;;
        esac;;
      (-*)
        fail_with "Unrecognized option ${1}";;
      (*)
        fail_with "Unexpected argument ${1}";;
    esac
  done

  [[ -z "${_downloaded_binaries_dir:-}" ]] && fail_with "Must provide --downloaded-binaries-dir"

  _published_blobs=$(bosh blobs --json | jq --compact-output '.Tables[0].Rows[] | {path, digest}')

  # Prune Bosh release
  print_stderr "Removing blobs from Bosh release that do not match downloaded binaries"
  for _published_blob in ${_published_blobs}; do
    _published_blob_name=$(echo "${_published_blob}" | jq --raw-output '.path')
    _resolved_tarball=$(find "${_downloaded_binaries_dir}"/* -type f -name "${_published_blob_name}" | head -1)

    # Failed to find named tarball - Prune
    if [[ -z "${_resolved_tarball}" ]]; then
      print_stderr "Published blob ${_published_blob_name} does not have corresponding downloaded binary. Removing from new release."
      bosh remove-blob "${_published_blob_name}"

    # Found named tarball - Compare digests
    else
      _published_blob_digest=$(echo "${_published_blob}" | jq --raw-output '.digest')
      _downloaded_tarball_digest="sha256:$(sha256sum "${_resolved_tarball}" | cut --delimiter ' ' --field 1)"

      # Digest mismatch - Prune
      if [[ "${_published_blob_digest}" != "${_downloaded_tarball_digest}" ]]; then
        print_stderr "Downloaded binary ${_published_blob_name} does not match blob in published Bosh release (published release specifies digest ${_published_blob_digest}, downloaded binary has digest ${_downloaded_tarball_digest}). Removing from new release."
      
        bosh remove-blob "${_published_blob}"
      else
        print_stderr "Downloaded binary ${_published_blob_name} has same digest as blob in published release: ${_published_blob_digest}. Disregarding."
      fi
    fi
  done

  # Update so that subsequent operations use newly-pruned blobs
  _updated_published_blobs=$(bosh blobs --json | jq --compact-output '.Tables[0].Rows[] | {path, digest}')

  # Find tarball
  tarball_regex="^.*/cf[0-9]?-cli_([0-9]+\.[0-9]+\.[0-9]+)_linux_x86-64\.tgz$" \
  _downloaded_tarballs=$(find "${_downloaded_binaries_dir}"/* \
    -type f \
    -regextype posix-extended \
    -regex "${tarball_regex}")

  for _downloaded_tarball in ${_downloaded_tarballs}; do
    _downloaded_tarball_basename=$(basename "${_downloaded_tarball}")
    _downloaded_tarball_major_version=$(basename "$(dirname "${_downloaded_tarball}")")
    _published_blob=$(echo "${_updated_published_blobs}" | jq ". | select(.path == \"${_downloaded_tarball_basename}\")")

    if [[ -z "${_published_blob}" ]]; then
      print_stderr "Downloaded binary ${_downloaded_tarball_basename} has no corresponding blob in published Bosh release. Adding to new release."

      bosh add-blob "${_downloaded_tarball}" "${_downloaded_tarball_basename}"

    else
      _published_tarball_digest=$(echo "${_published_blob}" | jq --raw-output '.digest')
      _downloaded_tarball_digest="sha256:$(sha256sum "${_downloaded_tarball}" | cut --delimiter ' ' --field 1)"

      if [[ "${_published_tarball_digest}" != "${_downloaded_tarball_digest}" ]]; then
        print_stderr "Downloaded binary ${_downloaded_tarball} does not match blob in published Bosh release (published release specifies digest ${_published_tarball_digest}, downloaded binary has digest ${_downloaded_tarball_digest}). Adding to new release."

        bosh add-blob "${_downloaded_tarball}" "${_downloaded_tarball_basename}"
      else
        print_stderr "Downloaded binary ${_downloaded_tarball_basename} has same digest as blob in published release: ${_published_tarball_digest}. Disregarding."
      fi
    fi
  done

  # bosh create-release --timestamp-version --tarball=./candidate-release-output/cf-cli-dev-release.tgz
}

# Was the script sourced or executed?
if [[ "$(realpath "${0}")" == "$(realpath "${BASH_SOURCE[0]}")" ]]; then
  create_bosh_release_candidate "$@"
fi



# git config --global --add safe.directory "$(pwd)"

# create_bosh_release_candidate() {
#     cli_version_major=$1

#     latest_cli_version=$(ls -1 v${cli_version_major}-cli-binary | grep "^cf${cli_version_major}-cli" | cut -d_ -f2)
#     old_blob_path=$(bosh blobs --column=path | grep "cf${cli_version_major}-cli" | tr -d '[:space:]')
#     old_cli_version=$(echo "${old_blob_path:?}" | cut -d_ -f2)

#     if [[ "${old_cli_version:?}" != "${latest_cli_version:?}" ]]; then
#         git config user.name  "github-actions[bot]"
#         git config user.email "41898282+github-actions[bot]@users.noreply.github.com "

#         echo "Bosh Blobs: initial state"
#         bosh blobs
#         bosh remove-blob "${old_blob_path}"

#         echo "Bosh Blobs: without old blob"
#         bosh blobs
#         bosh add-blob "v${cli_version_major}-cli-binary/cf${cli_version_major}-cli_${latest_cli_version}_linux_x86-64.tgz" "cf${cli_version_major}-cli_${latest_cli_version}_linux_x86-64.tgz"

#         echo "Bosh Blobs: added new blob"
#         bosh blobs
#         #TODO: add bosh upload-blobs

#         git status
#         git add config/blobs.yml
#         git status
#         git commit -m "bump v${cli_version_major} cli from ${old_cli_version} to ${latest_cli_version}"

#         echo "blobs_updated=yes" >> $GITHUB_OUTPUT
#     else
#         echo "Release has latest v${cli_version_major} CLI version, skipping bump."

#         # echo "blobs_updated=no" >> $GITHUB_OUTPUT
#     fi

#     git log -3
# }