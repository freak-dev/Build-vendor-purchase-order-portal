$ErrorActionPreference = 'Stop'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Run this script from an Administrator PowerShell window.'
}

$wslIpOutput = & wsl.exe -d Ubuntu -u root -- hostname -I
if ($LASTEXITCODE -ne 0) { throw 'Could not read the Ubuntu WSL network address.' }
$wslIp = ($wslIpOutput -split '\s+')[0]
if (-not $wslIp) { throw 'Ubuntu WSL returned no IPv4 address.' }

$listenAddress = '127.0.0.1'
$port = 8088
& netsh.exe interface portproxy delete v4tov4 listenaddress=$listenAddress listenport=$port 2>$null | Out-Null
& netsh.exe interface portproxy add v4tov4 listenaddress=$listenAddress listenport=$port connectaddress=$wslIp connectport=$port
if ($LASTEXITCODE -ne 0) { throw 'Windows could not create the localhost port forward.' }

Write-Output "Forwarded http://localhost:$port to Ubuntu WSL at $wslIp`:$port."
Write-Output 'This listens on loopback only. Re-run after WSL restarts if its IP changes.'
