#!/bin/bash

set -e

export BOSH_DEPLOYMENT=cf-cli-test
export BOSH_NON_INTERACTIVE=true

echo "-----> `date`: Delete previous deployment"
bosh delete-deployment --force

echo "-----> `date`: Deploy"
bosh deploy ./manifests/test.yml

echo "-----> `date`: Run test errand for cf6-linux"
bosh run-errand cf-cli-6-linux-test

echo "-----> `date`: Run test errand for cf6-windows"
bosh run-errand cf-cli-6-windows-test

echo "-----> `date`: Run test errand for cf7-linux"
bosh run-errand cf-cli-7-linux-test

echo "-----> `date`: Run test errand for cf7-windows"
bosh run-errand cf-cli-7-windows-test

echo "-----> `date`: Run test errand for cf8-linux"
bosh run-errand cf-cli-8-linux-test

echo "-----> `date`: Run test errand for cf8-windows"
bosh run-errand cf-cli-8-windows-test

echo "-----> `date`: Delete deployments"
bosh delete-deployment

echo "-----> `date`: Clean up"
bosh clean-up --all

echo "-----> `date`: Done"
