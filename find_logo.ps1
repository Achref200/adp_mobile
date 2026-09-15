$lib = 'C:\Users\Team_2\proejcts\adp_mobile\lib'
$files = Get-ChildItem -LiteralPath $lib -Recurse -File -Filter '*.dart'
foreach ($f in $files) {
  $c = Get-Content -LiteralPath $f.FullName -Raw
  if ($c -match 'logo_adp|Image\.asset|AssetImage|assets/brand|brand/logo') {
    $f.FullName
  }
}
