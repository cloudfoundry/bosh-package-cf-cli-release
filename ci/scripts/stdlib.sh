# shellcheck disable=SC2148
fail_with() {
  echo -e "ERROR: ${1}"
  exit 1
}
