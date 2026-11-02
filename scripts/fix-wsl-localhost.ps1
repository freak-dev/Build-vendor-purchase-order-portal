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
$rules = & netsh.exe interface portproxy show v4tov4
$existing = $rules | Where-Object { $_ -match '^\s*127\.0\.0\.1\s+8088\s+(\S+)\s+(\d+)\s*$' } | Select-Object -First 1
if ($existing -and $existing -match '^\s*127\.0\.0\.1\s+8088\s+(\S+)\s+(\d+)\s*$') {
  $oldTarget = $Matches[1]
  $oldPort = $Matches[2]
  if ($oldTarget -eq $wslIp -and $oldPort -eq "$port") {
    Write-Output "http://localhost:$port is already forwarded to Ubuntu WSL at $wslIp`:$port."
    exit 0
  }
  if ($oldPort -ne "$port" -or $oldTarget -notmatch '^172\.(1[6-9]|2[0-9]|3[01])\.') {
    throw "Refusing to replace an unrelated localhost port forward (127.0.0.1:$port -> $oldTarget`:$oldPort)."
  }
  & netsh.exe interface portproxy delete v4tov4 listenaddress=$listenAddress listenport=$port | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'Could not remove the stale WSL localhost port forward.' }
}
& netsh.exe interface portproxy add v4tov4 listenaddress=$listenAddress listenport=$port connectaddress=$wslIp connectport=$port
if ($LASTEXITCODE -ne 0) { throw 'Windows could not create the localhost port forward.' }

Write-Output "Forwarded http://localhost:$port to Ubuntu WSL at $wslIp`:$port."
Write-Output 'This listens on loopback only. Re-run after WSL restarts if its IP changes.'
