# GHA Workflows

## [Create Bosh Release](create-bosh-release.yml)

Why? To create a new cf cli bosh release including major cli versions.

### Resources
- [Old Concourse implementation of the release pipeline](https://ci.cli.fun/teams/main/pipelines/cf-cli-release-toolsmiths)
    - [pipeline definition](../../ci/pipeline-toolsmiths.yml)

### Plan

- Acquire cf cli linux binaries for v6, v7, and v8 from s3
- Detect latest tag under each major version

- ...

- Upload (where?) newly created cf cli bosh release.
- Update Releases section on GitHub https://github.com/cloudfoundry/bosh-package-cf-cli-release/releases