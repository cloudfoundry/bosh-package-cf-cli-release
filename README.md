# cf-cli-release

This release allows a BOSH release author to install a specific *blessed version of the CF CLI binary in their deployment.

*blessed: the CF CLI binary is signed with a Cloud Foundry Foundation certificate, certifying that the source code has not been tampered with.

## This release can be consumed as follows:

### via BOSH vendor-package

To vendor the Linux CF CLI BOSH package into your release, run:

```
$ cd ~/workspace
$ git clone https://github.com/bosh-packages/cf-cli-release
$ cd ~/workspace/your-bosh-release
$ bosh vendor-package cf-cli-6-linux ~/workspace/cf-cli-release
```

This will copy the Linux CF CLI Bosh package into your bosh release, readily available for your BOSH jobs to utilize as a package dependency.

For examples, see the [BOSH documentation on vendor-package](https://bosh.io/docs/package-vendoring.html)

Included packages:

* cf-cli-6-linux

### via co-locating the CF CLI BOSH job

To co-locate the Linux CF CLI BOSH job on your target VM, follow these steps:

1. add the "cf-cli" BOSH release to your deployment manifest
2. add the "cf-cli-6-linux" BOSH job on the VM you want to install the CF CLI binary on
3. in one of your BOSH job scripts on the same VM, add the following bash command `source /var/vcap/packages/cf-cli-6-linux/bosh/runtime.env` before any command that calls the `cf` binary

Behind the scenes, the CF CLI binary is installed on the target machine at compile time via the "cf-cli-6-linux" BOSH package (dependency of the "cf-cli-6-linux" BOSH job). Your BOSH job script runs the bash command to add the `cf` binary to PATH.

## Development

To test installation of the CF CLI binary via BOSH job co-location, run:

```
$ ./tests/run.sh
```

This will create a deployment using your currently targeted BOSH Director.
