#!/bin/sh

image_id=$(docker ps --format=json | jq --slurp '.[] | select(.Image == "cfcli/cli-release-base") | .ID' --raw-output)
docker exec --interactive --tty "${image_id}" /bin/bash