# cf-cli-release

This release allows a BOSH release author to install a specific *official version of the CF CLI binary in their deployment. The release currently comprises two major versions of the CLI: v7 (via the `cf-cli-7-linux` package) and v8 (via the `cf-cli-8-linux` package).

*official: the CF CLI binary is signed with a Cloud Foundry Foundation certificate, certifying that the source code has not been tampered with.

## Consuming the release

To co-locate the Linux CF CLI BOSH job on your target VM, follow these steps:

1. Add the `cf-cli` BOSH release to your deployment manifest.
2. Colocate either the `cf-cli-7-linux` or `cf-cli-8-linux` BOSH job on the instance group you want to use the CF CLI binary on.
3. Modify your BOSH job script that uses the cli to add the `cf` binary of your choice to the PATH.

Behind the scenes, the CF CLI binary is installed on the target machine at compile time via the `cf-cli-7-linux` or `cf-cli-8-linux` BOSH package (dependency of the `cf-cli-(7 | 8)-linux` BOSH job). The binary will be located at `/var/vcap/packages/cf-cli-(7 | 8)-linux/bin/cf`.

### Warning
Before consuming the release, ensure you've removed all previous `cf` CLI from either your blobs or packages. 


## Development

To test installation of the CF CLI binary via BOSH job co-location, run:

```
$ ./tests/run.sh
```

This will create a deployment using your currently targeted BOSH Director.
