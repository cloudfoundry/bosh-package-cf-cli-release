$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:PATH="c:\var\vcap\packages\cf-cli-7-windows;$env:PATH"
Move-Item -Path C:\var\vcap\packages\cf-cli-7-windows\cf7.exe -Destination C:\var\vcap\packages\cf-cli-7-windows\cf.exe
cf.exe version
