#!/bin/bash

set -e

DEPLOYMENT_NAME=test-cf-cli-bosh-release

echo "-----> `date`: Delete previous deployment"
bosh -n -d $DEPLOYMENT_NAME delete-deployment --force

echo "-----> `date`: Deploy"
( set -e; bosh -n -d $DEPLOYMENT_NAME deploy ./manifests/test.yml )

echo "-----> `date`: Run test errand"
bosh -n -d $DEPLOYMENT_NAME run-errand linux-32-test

echo "-----> `date`: Delete deployments"
bosh -n -d $DEPLOYMENT_NAME delete-deployment

echo "-----> `date`: Done"
