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

1. Open with VisualStudion Code
   - Check if [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension is installed.
1. By default [.vars](.github/.vars) and [.secrets](.github/.secrets) located in [.github](.github) folder. To use them please copy to the root of the project and update values. `cp .github/.vars .github/.secrets .`
1. Update [.secrets](.secrets) file with real API token.
   - `echo "API_TOKEN: $(shepherd create service-account gha-shepherd --json | jq -r .secret)" >> .secrets`
   - Local workflow dev runner [act](https://github.com/nektos/act) injects content of [.vars](.vars) and [.secrets](.secrets) into workflow execution context.
1. Open project inside the dev container.
1. Run `make run` to start.

## Deployment

1. To upload variables and secrets to the default remote repo for the current branch. **PROCEED WITH CARE** use `make repo-context-setup`. This will overwrite remote vaules with local from [.vars](.vars) and [.secrets](.secrets)

To test installation of the CF CLI binary via BOSH job co-location, run:

```sh
./tests/run.sh
```

This will create a deployment using your currently targeted BOSH Director.
