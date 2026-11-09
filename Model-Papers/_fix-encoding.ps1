# Fix mojibake and smart punctuation in model papers + build script.
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Fix-Text([string]$text) {
  # Mojibake sequences (UTF-8 read as Windows-1252)
  $text = $text.Replace([string]([char]0x00E2) + [char]0x20AC + [char]0x201D, '-')   # â€” emdash garbled sometimes varies
  # Direct byte-pattern replacements as literal strings commonly seen:
  $map = [ordered]@{
    'â€”' = '-'
    'â€“' = '-'
    'â€™' = "'"
    'â€˜' = "'"
    'â€œ' = '"'
    'â€' = '"'
    'â‰¥' = '>='
    'â€¦' = '...'
  }
  foreach ($k in $map.Keys) { $text = $text.Replace($k, $map[$k]) }

  # Real Unicode smart chars if present
  $text = $text.Replace([char]0x2014, '-')
  $text = $text.Replace([char]0x2013, '-')
  $text = $text.Replace([char]0x2018, "'")
  $text = $text.Replace([char]0x2019, "'")
  $text = $text.Replace([char]0x201C, '"')
  $text = $text.Replace([char]0x201D, '"')
  $text = $text.Replace([char]0x2026, '...')
  $text = $text.Replace([char]0x2265, [string]'>' + '=')
  return $text
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false

$files = @()
$files += Get-ChildItem (Join-Path $dir 'Model-Paper-*.html')
$files += Get-Item (Join-Path $dir 'build-model-papers.ps1')
$files += Get-Item (Join-Path $dir '_papers-meta.json')

foreach ($f in $files) {
  $raw = [System.IO.File]::ReadAllText($f.FullName)
  $fixed = Fix-Text $raw
  if ($fixed -ne $raw) {
    [System.IO.File]::WriteAllText($f.FullName, $fixed, $utf8NoBom)
    Write-Host "Fixed: $($f.Name)"
  } else {
    Write-Host "OK (no change): $($f.Name)"
  }
}

# Verify no remaining mojibake marker
$left = Select-String -Path (Join-Path $dir 'Model-Paper-*.html') -Pattern 'â€' -SimpleMatch
if ($left) {
  Write-Host "WARNING: still found mojibake:"
  $left | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber)" }
} else {
  Write-Host "All HTML papers clean of mojibake marker."
}

# Spot-check paper 01
$sample = Select-String -Path (Join-Path $dir 'Model-Paper-01-Easy.html') -Pattern 'Loops'
$sample | ForEach-Object { Write-Host "SAMPLE: $($_.Line.Trim())" }
