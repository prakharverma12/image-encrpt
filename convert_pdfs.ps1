$src = "realpdfs"
$dst = "base64"

New-Item -ItemType Directory -Force $dst | Out-Null

$entries = @()
$skipped = 0
Get-ChildItem $src -Filter "*.pdf" | ForEach-Object {
    # Only include PDFs with a traditional xref table (not PDF 1.5+ xref streams).
    # buildVaultPdf needs /Size and /Root in a plain trailer dict at the file tail.
    $bytes = [IO.File]::ReadAllBytes($_.FullName)
    $tailLen = [Math]::Min(1024, $bytes.Length)
    $tail = [Text.Encoding]::GetEncoding('latin1').GetString($bytes, $bytes.Length - $tailLen, $tailLen)
    if ($tail -notmatch 'trailer\s*<<') {
        Write-Host "Skipped (xref stream / incompatible): $($_.Name)"
        $skipped++
        return
    }
    $b64 = [Convert]::ToBase64String($bytes)
    $out = $_.Name + ".b64"
    [IO.File]::WriteAllText("$PWD\$dst\$out", $b64)
    $entries += $out
    Write-Host "Converted: $($_.Name)"
}

$entries | ConvertTo-Json | Set-Content "$dst\manifest.json" -Encoding utf8
Write-Host "Done: $($entries.Count) converted, $skipped skipped → $dst\manifest.json"
