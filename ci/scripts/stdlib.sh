#!/bin/bash
set -o errexit -o nounset -o pipefail
[[ "${TRACE:-0}" == "1" ]] && set -o xtrace

fail_with() {
  echo -e "ERROR: ${1}"
  exit 1
}
