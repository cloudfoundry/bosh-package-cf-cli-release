#!/bin/bash

set -e

export BOSH_DEPLOYMENT=cf-cli-test
export BOSH_NON_INTERACTIVE=true

echo "-----> `date`: Delete previous deployment"
bosh delete-deployment --force

echo "-----> `date`: Deploy"
bosh deploy ./manifests/test.yml

echo "-----> `date`: Run test errand"
bosh run-errand cf-cli-6-linux-test

echo "-----> `date`: Delete deployments"
bosh delete-deployment

echo "-----> `date`: Clean up"
bosh clean-up --all

echo "-----> `date`: Done"
