$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$jdk = Get-ChildItem (Join-Path $root '.tools/java') -Directory | Select-Object -First 1
$maven = Get-ChildItem (Join-Path $root '.tools/maven') -Directory | Select-Object -First 1
if (-not $jdk -or -not $maven) { throw 'Portable Java/Maven are not present. See README.md to install Java 21 and Maven 3.9+.' }
$env:JAVA_HOME = $jdk.FullName
$mvn = Join-Path $maven.FullName 'bin/mvn.cmd'
Push-Location (Join-Path $root 'backend')
try { & $mvn -B verify; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } } finally { Pop-Location }
Push-Location (Join-Path $root 'frontend')
try { npm ci; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; npm run build; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } } finally { Pop-Location }
