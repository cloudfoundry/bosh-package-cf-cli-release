#!/bin/bash
set -o errexit -o nounset -o pipefail
[[ "${TRACE:-0}" == "1" ]] && set -o xtrace

# TODO: How do we configure shellcheck to find the right file?
# See https://www.shellcheck.net/wiki/SC1091
# shellcheck source=/dev/null
. "$(dirname "${BASH_SOURCE[0]}")"/stdlib.sh

compare_against_published_bosh_release() {
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

  # Start off assuming no updates
  _blobs_updated=false

  print_stderr "Blobs in most recent Bosh release:\n$(bosh blobs)"
  _published_blobs=$(bosh blobs --json | jq --compact-output '.Tables[0].Rows[] | {path, digest}')

  # Compare each published blob with tarball
  print_stderr "Comparing each blob in the most-recent Bosh release against downloaded binaries"
  for _published_blob in ${_published_blobs}; do
    _tarball_name=$(echo "${_published_blob}" | jq --raw-output '.path')
    _resolved_tarball=$(find "${_downloaded_binaries_dir}"/* -type f -name "${_tarball_name}" | head -1)

    # Failed to find named tarball
    if [[ -z "${_resolved_tarball}" ]]; then
      _blobs_updated=true

      print_stderr "Downloaded binaries do not include ${_tarball_name}. New release necessary."

    # Found named tarball; compare digests
    else
      _published_tarball_digest=$(echo "${_published_blob}" | jq --raw-output '.digest')
      _downloaded_tarball_digest="sha256:$(sha256sum "${_resolved_tarball}" | cut --delimiter ' ' --field 1)"

      # Digest mismatch - new Bosh release required
      if [[ "${_published_tarball_digest}" != "${_downloaded_tarball_digest}" ]]; then
        _blobs_updated=true

        print_stderr "Downloaded binary ${_tarball_name} does not match blob in published Bosh release (published release specifies digest ${_published_tarball_digest}, downloaded binary has digest ${_downloaded_tarball_digest}). New release necessary."

      # Digest match - this CF CLI version, at least, does not require a new release
      else
        print_stderr "Downloaded binary ${_tarball_name} has same digest as blob in published release: ${_published_tarball_digest}. Disregarding."
      fi
    fi
  done


  # Compare each tarball against published blobs
  print_stderr "Comparing each downloaded binary against blobs in the most-recent Bosh release"

  # Find tarball
  tarball_regex="^.*/cf[0-9]?-cli_([0-9]+\.[0-9]+\.[0-9]+)_linux_x86-64\.tgz$" \
  _downloaded_tarballs=$(find "${_downloaded_binaries_dir}"/* \
    -type f \
    -regextype posix-extended \
    -regex "${tarball_regex}")

  for _downloaded_tarball in ${_downloaded_tarballs}; do
    _downloaded_tarball_basename=$(basename "${_downloaded_tarball}")
    _published_blob=$(echo "${_published_blobs}" | jq ". | select(.path == \"${_downloaded_tarball_basename}\")")

    if [[ -z "${_published_blob}" ]]; then
      _blobs_updated=true

      print_stderr "Downloaded binary ${_downloaded_tarball_basename} has no corresponding blob in published Bosh release. New release necessary."
    else
      _published_tarball_digest=$(echo "${_published_blob}" | jq --raw-output '.digest')
      _downloaded_tarball_digest="sha256:$(sha256sum "${_downloaded_tarball}" | cut --delimiter ' ' --field 1)"

      # Digest mismatch - new Bosh release required
      if [[ "${_published_tarball_digest}" != "${_downloaded_tarball_digest}" ]]; then
        _blobs_updated=true

        print_stderr "Downloaded binary ${_downloaded_tarball} does not match blob in published Bosh release (published release specifies digest ${_published_tarball_digest}, downloaded binary has digest ${_downloaded_tarball_digest}). New release necessary."

      # Digest match - this CF CLI version, at least, does not require a new release
      else
        print_stderr "Downloaded binary ${_tarball_name} has same digest as blob in published release: ${_published_tarball_digest}. Disregarding."
      fi
    fi
  done

  echo "blobs_updated=${_blobs_updated}"
}

# Was the script sourced or executed?
if [[ "$(realpath "${0}")" == "$(realpath "${BASH_SOURCE[0]}")" ]]; then
  compare_against_published_bosh_release "$@"
fi
