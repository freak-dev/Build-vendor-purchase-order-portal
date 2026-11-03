$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$localJdk = Get-ChildItem (Join-Path $root '.tools/java') -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
$localMaven = Get-ChildItem (Join-Path $root '.tools/maven') -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
if ($localJdk -and $localMaven) {
  $env:JAVA_HOME = $localJdk.FullName
  $mvn = Join-Path $localMaven.FullName 'bin/mvn.cmd'
} else {
  $javaCommand = Get-Command java -ErrorAction SilentlyContinue
  $mavenCommand = Get-Command mvn -ErrorAction SilentlyContinue
  if (-not $javaCommand -or -not $mavenCommand) { throw 'Java 21 and Maven 3.9+ are required. Install them or place portable builds under .tools/java and .tools/maven.' }
  $mvn = $mavenCommand.Source
}
Push-Location (Join-Path $root 'backend')
try { & $mvn -B verify; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } } finally { Pop-Location }
Push-Location (Join-Path $root 'frontend')
try { npm ci; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; npm run build; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } } finally { Pop-Location }
