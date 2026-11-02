param([string]$SeleniumMethod = '')
$ErrorActionPreference = 'Stop'
$projectWsl = '/mnt/c/Users/areyy/OneDrive/Documents/ChatGPT/Vendor-Purchase-Order-Portal'
$secretPath = '/home/areyy/.config/vendor-portal/.env'

& wsl.exe -d Ubuntu -u root -- test -f $secretPath
if ($LASTEXITCODE -eq 0) {
  $saved = & wsl.exe -d Ubuntu -u root -- cat $secretPath
  foreach ($line in $saved) {
    if ($line -match '^ADMIN_PASSWORD=(.*)$') { $env:PORTAL_ADMIN_PASSWORD = $Matches[1] }
    if ($line -match '^DB_PASSWORD=(.*)$') { $env:PORTAL_DB_PASSWORD = $Matches[1] }
    if ($line -match '^MYSQL_ROOT_PASSWORD=(.*)$') { $env:PORTAL_MYSQL_ROOT_PASSWORD = $Matches[1] }
  }
} else {
  function New-Secret {
    $bytes = [byte[]]::new(32)
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+','-').Replace('/','_')
  }
  $env:PORTAL_ADMIN_PASSWORD = New-Secret
  $env:PORTAL_DB_PASSWORD = New-Secret
  $env:PORTAL_MYSQL_ROOT_PASSWORD = New-Secret
}
$env:WSLENV = 'PORTAL_ADMIN_PASSWORD/u:PORTAL_DB_PASSWORD/u:PORTAL_MYSQL_ROOT_PASSWORD/u'
$env:PORTAL_IT_METHOD = $SeleniumMethod
$env:WSLENV += ':PORTAL_IT_METHOD/u'
& wsl.exe -d Ubuntu -u root -- bash "$projectWsl/scripts/start-compose-wsl.sh"
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose startup failed.' }
& wsl.exe -d Ubuntu -u root -- bash "$projectWsl/scripts/run-integration-wsl.sh"
if ($LASTEXITCODE -ne 0) { throw 'Selenium or Playwright integration checks failed.' }
Write-Output 'Backend health, Selenium, and Playwright checks passed. Compose remains running on port 8088; credentials are stored in WSL only.'
