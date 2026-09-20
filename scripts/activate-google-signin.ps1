# Activates Google Sign-In once you have the OAuth Web client ID.
# Usage:  powershell -ExecutionPolicy Bypass -File scripts\activate-google-signin.ps1 -ClientId "xxxx.apps.googleusercontent.com"
param(
  [Parameter(Mandatory = $true)]
  [string]$ClientId
)

if ($ClientId -notmatch '^[0-9a-z-]+\.apps\.googleusercontent\.com$') {
  Write-Error "That doesn't look like a Google OAuth client ID (expected: xxxx.apps.googleusercontent.com)."
  exit 1
}

Write-Host "==> 1/4 Adding GOOGLE_CLIENT_ID to Vercel (production + preview)..."
vercel env add GOOGLE_CLIENT_ID production --force $ClientId 2>&1 | Select-Object -First 1
vercel env add GOOGLE_CLIENT_ID preview --force $ClientId 2>&1 | Select-Object -First 1

Write-Host "==> 2/4 Adding to backend/.env for local runs..."
$envPath = Join-Path $PSScriptRoot '..\backend\.env'
$envText = Get-Content $envPath -Raw
if ($envText -match '(?m)^GOOGLE_CLIENT_ID=') {
  $envText = $envText -replace '(?m)^GOOGLE_CLIENT_ID=.*$', "GOOGLE_CLIENT_ID=$ClientId"
} else {
  $envText = $envText.TrimEnd() + "`nGOOGLE_CLIENT_ID=$ClientId`n"
}
Set-Content $envPath $envText -NoNewline

Write-Host "==> 3/4 Rebuilding Flutter web with the client ID baked in (takes ~3 min)..."
flutter build web --dart-define=GOOGLE_CLIENT_ID=$ClientId 2>&1 | Select-Object -Last 2

Write-Host "==> 4/4 Committing and pushing (Vercel redeploys automatically)..."
git add -A
git commit -m "feat: activate Google Sign-In with production OAuth client ID"
git push origin master 2>&1 | Select-Object -Last 1

Write-Host ""
Write-Host "DONE. Wait ~4 minutes for the Vercel deploy, then test the 'Continuer avec Google' button."
Write-Host "NOTE: backend/.env is gitignored — the client ID reaching Vercel is what matters for production."
