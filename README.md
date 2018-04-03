# cf-cli-release

This release allows a BOSH release author to install a specific *blessed version of the CF CLI binary in their deployment.

*blessed: the CF CLI binary is signed with a Cloud Foundry Foundation certificate, certifying that the source code has not been tampered with.

## Consuming the release

To co-locate the Linux CF CLI BOSH job on your target VM, follow these steps:

1. Add the "cf-cli" BOSH release to your deployment manifest.
2. Colocate the "cf-cli-6-linux" BOSH job in the instance group you want to install the CF CLI binary on.
3. Modify your BOSH job script that uses the cli to add the `cf` binary to PATH.

Behind the scenes, the CF CLI binary is installed on the target machine at compile time via the "cf-cli-6-linux" BOSH package (dependency of the "cf-cli-6-linux" BOSH job). The binary is located at `/var/vcap/packages/cf-cli-6-linux/bin/cf`.

## Development

To test installation of the CF CLI binary via BOSH job co-location, run:

```
$ ./tests/run.sh
```

This will create a deployment using your currently targeted BOSH Director.
