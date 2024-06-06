#!/bin/bash
set -o errexit -o nounset -o pipefail

artifacts_dir="/tmp/artifacts/1"
artifacts_file="${artifacts_dir}/lease-json/lease-json.zip"
env_file=lease.json

pushd "$(mktemp -d)"
  unzip "${artifacts_file}"
  jq -r .output ${env_file} > bosh_metadata.json
  env_name=$(jq -r .name bosh_metadata.json)
  jq -r .bosh.jumpbox_private_key bosh_metadata.json > "/tmp/${env_name:?}.priv"
  eval "$(bbl print-env --metadata-file bosh_metadata.json)"
popd

bosh deployments
bash