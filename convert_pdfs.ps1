$src = "realpdfs"
$dst = "base64"

New-Item -ItemType Directory -Force $dst | Out-Null

$entries = @()
Get-ChildItem $src -Filter "*.pdf" | ForEach-Object {
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName))
    $out = $_.Name + ".b64"
    [IO.File]::WriteAllText("$PWD\$dst\$out", $b64)
    $entries += $out
    Write-Host "Converted: $($_.Name)"
}

$entries | ConvertTo-Json | Set-Content "$dst\manifest.json" -Encoding utf8
Write-Host "Done: $($entries.Count) PDF(s) converted → $dst\manifest.json"
