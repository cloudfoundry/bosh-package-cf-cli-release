#!/bin/bash
set -o errexit -o nounset -o pipefail
[[ "${TRACE:-0}" == "1" ]] && set -o xtrace

# TODO: How do we configure shellcheck to find the right file?
# See https://www.shellcheck.net/wiki/SC1091
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")"/stdlib.sh

# Used to find downloaded tarballs and extract semver
tarball_regex_sed="^.*cf[[:digit:]]\?-cli_\([[:digit:]]\+\).\([[:digit:]]\+\).\([[:digit:]]\+\)_linux_x86-64.tgz$"

diff_and_commit_with_message() {
  _message=${1}

  git diff --patch config/blobs.yml
  git add config/blobs.yml
  git commit --message "${_message}"
  git log --pretty=full --max-count=1
}

add_and_commit_blob() {
  _downloaded_tarball=${1}
  _downloaded_tarball_basename=$(basename "${_downloaded_tarball}")

  # shellcheck disable=SC2001
  _major_version=$(echo "${_downloaded_tarball_basename}" | sed "s/${tarball_regex_sed}/\1/")
  # shellcheck disable=SC2001
  _full_version=$(echo "${_downloaded_tarball_basename}" | sed "s/${tarball_regex_sed}/\1.\2.\3/")

  echo "::group::Adding blob for v${_major_version} - ${_downloaded_tarball_basename}"
  bosh add-blob "${_downloaded_tarball}" "${_downloaded_tarball_basename}"
  diff_and_commit_with_message "Setting CF CLI v${_major_version} to ${_full_version}"
  echo "::endgroup::"
}

remove_and_commit_blob() {
  _published_blob_name=${1}

  # shellcheck disable=SC2001
  _major_version=$(echo "${_published_blob_name}" | sed "s/${tarball_regex_sed}/\1/")

  echo "::group::Removing blob for v${_major_version}"
  bosh remove-blob "${_published_blob_name}"
  diff_and_commit_with_message "Removing CF CLI v${_major_version}"
  echo "::endgroup::"
}

update_and_commit_blob() {
  _published_blob_name=${1}
  _downloaded_tarball=${2}

  _downloaded_tarball_basename=$(basename "${_downloaded_tarball}")
  # shellcheck disable=SC2001
  _major_version=$(echo "${_downloaded_tarball_basename}" | sed "s/${tarball_regex_sed}/\1/")
  # shellcheck disable=SC2001
  _published_version=$(echo "${_published_blob_name}" | sed "s/${tarball_regex_sed}/\1.\2.\3/")
  # shellcheck disable=SC2001
  _new_version=$(echo "${_downloaded_tarball_basename}" | sed "s/${tarball_regex_sed}/\1.\2.\3/")

  echo "::group::Adding blob for v${_major_version} - ${_downloaded_tarball_basename}"
  bosh add-blob "${_downloaded_tarball}" "${_downloaded_tarball_basename}"
  diff_and_commit_with_message "Updating CF CLI v${_major_version} from ${_published_version} to ${_new_version}"
  echo "::endgroup::"
}

create_bosh_release_candidate() {
  ## Parse and validate arguments
  while [ ${#} -gt 0 ] ; do
    case "${1}" in
      --downloaded-binaries-dir)
        case "${2:-}" in
          "") fail_with "Must provide value for --downloaded-binaries-dir";;
          *) _downloaded_binaries_dir="${2}"; shift 2;;
        esac;;
      --git-email)
        case "${2:-}" in
          "") fail_with "Must provide value for --git-email";;
          *) _git_email="${2}"; shift 2;;
        esac;;
      --git-username)
        case "${2:-}" in
          "") fail_with "Must provide value for --git-username";;
          *) _git_username="${2}"; shift 2;;
        esac;;
      (-*)
        fail_with "Unrecognized option ${1}";;
      (*)
        fail_with "Unexpected argument ${1}";;
    esac
  done


  [[ -z "${_downloaded_binaries_dir:-}" ]] && fail_with "Must provide --downloaded-binaries-dir"
  [[ -z "${_git_email:-}" ]] && fail_with "Must provide --git-email"
  [[ -z "${_git_username:-}" ]] && fail_with "Must provide --git-username"

  # Start off assuming no updates
  _blobs_updated=false

  # Configure git
  git config --global --add safe.directory "$(pwd)"
  git config --global user.name  "${_git_username}"
  git config --global user.email "${_git_email}"

  # Remember current blobs
  echo "::group::Blobs in most recent Bosh release:"
  bosh blobs
  _published_blobs=$(bosh blobs --json | jq --compact-output '.Tables[0].Rows[] | {path, digest}')
  echo "::endgroup::"

  ## STEP 1: Prune or replace mismatched blobs from current Bosh release
  echo "Replacing blobs from Bosh release that do not match downloaded binaries."

  for _published_blob in ${_published_blobs}; do
    _published_blob_name=$(echo "${_published_blob}" | jq --raw-output '.path')
    _resolved_tarball=$(find "${_downloaded_binaries_dir}"/* -type f -name "${_published_blob_name}")
    [[ $(echo "${_resolved_tarball}" | wc -l ) -gt 1 ]] && \
      ls -laR "${_downloaded_binaries_dir}" && \
      fail_with "Found multiple tarballs with name ${_published_blob_name} in ${_downloaded_binaries_dir}"

    # Failed to find named tarball - Prune
    if [[ -z "${_resolved_tarball}" ]]; then
      _blobs_updated=true

      echo "Published blob ${_published_blob_name} does not have corresponding downloaded binary. Removing from new release."
      remove_and_commit_blob  "${_published_blob_name}"

    # Found named tarball - Compare digests
    else
      _published_blob_digest=$(echo "${_published_blob}" | jq --raw-output '.digest')
      _downloaded_tarball_digest="sha256:$(sha256sum "${_resolved_tarball}" | cut --delimiter ' ' --field 1)"

      # Digest mismatch - Update
      if [[ "${_published_blob_digest}" != "${_downloaded_tarball_digest}" ]]; then
        _blobs_updated=true

        echo "Downloaded binary ${_published_blob_name} does not match blob in published Bosh release (published release specifies digest ${_published_blob_digest}, downloaded binary has digest ${_downloaded_tarball_digest}). Removing from new release."
      
        bosh remove-blob "${_published_blob}"
      else
        echo "Downloaded binary ${_published_blob_name} has same digest as blob in published release: ${_published_blob_digest}. Disregarding."
      fi
    fi
  done

  # Update so that subsequent operations use newly-pruned blobs
  _updated_published_blobs=$(bosh blobs --json | jq --compact-output '.Tables[0].Rows[] | {path, digest}')


  ## STEP 2: Add new blobs to bosh release
  echo "Adding downloaded binaries to the Bosh release."

  # Find tarballs
  _downloaded_tarballs=$(find "${_downloaded_binaries_dir}"/* \
    -type f \
    -regextype sed \
    -regex "${tarball_regex_sed}")

  for _downloaded_tarball in ${_downloaded_tarballs}; do
    _downloaded_tarball_basename=$(basename "${_downloaded_tarball}")
    _published_blob=$(echo "${_updated_published_blobs}" | jq ". | select(.path == \"${_downloaded_tarball_basename}\")")

    if [[ -z "${_published_blob}" ]]; then
      # Does downloaded tarball have a corresponding blob in the published Bosh release?
      _blobs_updated=true

      echo "Downloaded binary ${_downloaded_tarball_basename} has no corresponding blob in published Bosh release. Adding to new release."
      add_and_commit_blob "${_downloaded_tarball}"
    fi
  done

  bosh create-release \
    --timestamp-version \
    --force \
    --tarball=./cf-cli-dev-release.tgz

  echo "::group::Blobs in pending Bosh release"
  bosh blobs
  echo "::endgroup::"

  echo "blobs_updated=${_blobs_updated}" >> "${GITHUB_OUTPUT}"
}

# Was the script sourced or executed?
if [[ "$(realpath "${0}")" == "$(realpath "${BASH_SOURCE[0]}")" ]]; then
  create_bosh_release_candidate "$@"
fi
