$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:PATH="c:\var\vcap\packages\cf-cli-6-windows;$env:PATH"
cf.exe version
