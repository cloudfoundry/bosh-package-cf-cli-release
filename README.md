# cf-cli-release

This release contains cf-cli BOSH package that installs cf-cli and provides `runtime.env` that can extend the PATH to include `cf` binary.

## Vendoring

This release can be utilized by [bosh package vendoring](https://bosh.io/docs/package-vendoring.html).

To vendor cf-cli package for Linux 64 into your release, run:

```
$ git clone https://github.com/cloudfoundry-incubator/cf-cli-release
$ cd ~/workspace/your-release
$ bosh vendor-package cf-cli-linux-64 ~/workspace/cf-cli-release
```

Included packages:

* cf-cli-linux-64
* cf-cli-linux-32

## Using cf CLI in your BOSH scripts

To run `cf` binary for Linux 64 in your BOSH scripts source `runtime.env` to make it available in your PATH:

```bash
#!/bin/bash
source /var/vcap/packages/cf-cli-linux-64/bosh/runtime.env
cf -v
```

## Development

To run tests:

```
$ ./tests/test-linux-64.sh
```

This will create a deployment with cf-cli-release against your currently targeted BOSH Director.
