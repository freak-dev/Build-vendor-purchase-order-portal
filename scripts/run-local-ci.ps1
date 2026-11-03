$ErrorActionPreference = 'Stop'
$projectWsl = '/mnt/c/Users/areyy/OneDrive/Documents/ChatGPT/Vendor-Purchase-Order-Portal'
& wsl.exe -d Ubuntu -u root -- bash "$projectWsl/scripts/run-local-ci-wsl.sh"
if ($LASTEXITCODE -ne 0) { throw 'Local Jenkins/registry setup failed.' }
