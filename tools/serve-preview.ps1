param(
  [ValidateRange(1024, 65535)]
  [int]$Port = 4173
)

if (-not (Test-Path "$PSScriptRoot\..\build\web\index.html")) {
  throw 'The web bundle is missing. Ask the build machine or CI to run flutter build web first.'
}

# This serves an already-built static bundle. It does not run Flutter or use an emulator.
npx --yes serve -s "$PSScriptRoot\..\build\web" -l $Port
