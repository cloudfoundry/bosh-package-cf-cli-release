#!/bin/bash

set -e

export BOSH_DEPLOYMENT=cf-cli-test
export BOSH_NON_INTERACTIVE=true

echo "-----> $(date): Delete previous deployment"
bosh delete-deployment --force

echo "-----> $(date): Deploy"
bosh deploy ./manifests/test.yml

echo "-----> $(date): Run test errand for cf7"
bosh run-errand cf-cli-7-linux-test

echo "-----> $(date): Run test errand for cf8"
bosh run-errand cf-cli-8-linux-test

echo "-----> $(date): Delete deployments"
bosh delete-deployment

echo "-----> $(date): Clean up"
bosh clean-up --all

echo "-----> $(date): Done"
