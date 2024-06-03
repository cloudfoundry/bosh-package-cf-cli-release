#!/bin/bash
set -o errexit -o nounset -o pipefail
[[ "${TRACE:-0}" == "1" ]] && set -o xtrace

# TODO: How do we configure shellcheck to find the right file?
# See https://www.shellcheck.net/wiki/SC1091
# shellcheck source=/dev/null
. "$(dirname "${BASH_SOURCE[0]}")"/stdlib.sh

download_cf_cli_binary() {
  # Parse and validate arguments
  while [ ${#} -gt 0 ] ; do
    case "${1}" in
      --major-version)
        case "${2:-}" in
          "") fail_with "Must provide value for --major-version";;
          *) _major_version="${2}"; shift 2;;
        esac;;
      --output-dir)
        case "${2:-}" in
          "") fail_with "Must provide value for --output-dir, or leave blank to default to cwd";;
          *) _output_dir="${2}"; shift 2;;
        esac;;
      (-*)
        fail_with "Unrecognized option ${1}";;
      (*)
        fail_with "Unexpected argument ${1}";;
    esac
  done

  [[ -z "${_major_version:-}" ]] && fail_with "Must provide --major-version"
  [[ "${_major_version}" =~ [^0-9]+ ]] && fail_with "--major-version must be specified as number, e.g. \"8\" instead of \"v8\"."

  # Create named subdir in base output directory for version. Base output directory defaults to cwd if not specified.
  _resolved_output_dir="$(realpath -m "${_output_dir:-${PWD}}")/${_major_version}"


  # Download specified binary
  print_stderr "Downloading CF CLI ${_major_version} to directory ${_resolved_output_dir}"

  wget --trust-server-names \
    --directory-prefix "${_resolved_output_dir}" \
    --no-verbose \
     "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v${_major_version}&source=bosh-package-cf-cli-release-workflow"

  print_stderr "Download complete."
}


# Was the script sourced or executed?
if [[ "$(realpath "${0}")" == "$(realpath "${BASH_SOURCE[0]}")" ]]; then
  download_cf_cli_binary "$@"
fi
