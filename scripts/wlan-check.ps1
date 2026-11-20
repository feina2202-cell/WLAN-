<#
.SYNOPSIS
  WLAN-Kanalanalyse für Windows.
.DESCRIPTION
  Scannt die umliegenden WLANs mit "netsh wlan show networks mode=bssid", zeigt die Belegung pro Kanal
  und empfiehlt einen Kanal. Ändert nichts am Router.
  Je nach Windows-Version muss die Standortfreigabe (Einstellungen > Datenschutz > Standort) aktiv sein.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\wlan-check.ps1
#>

$ErrorActionPreference = 'Stop'

$raw = netsh wlan show networks mode=bssid 2>&1 | Out-String
if ($LASTEXITCODE -ne 0 -or $raw -match 'location|Standort') {
    if ($raw -notmatch 'BSSID') {
        Write-Host $raw
        Write-Host "Scan fehlgeschlagen. WLAN aktiv? Standortfreigabe für Desktop-Apps aktiviert?" -ForegroundColor Yellow
        exit 1
    }
}

# Ausgabe ist sprachabhängig: Felder per Muster erkennen (SSID, Signal, Kanal/Channel, Band)
$nets = @()
$ssid = ''
$cur = $null
foreach ($line in $raw -split "`r?`n") {
    if ($line -match '^SSID \d+\s*:\s*(.*)$') {
        $ssid = $Matches[1].Trim(); if (-not $ssid) { $ssid = '<versteckt>' }
    } elseif ($line -match '^\s+BSSID \d+\s*:') {
        if ($cur) { $nets += $cur }
        $cur = [pscustomobject]@{ SSID = $ssid; Signal = $null; Channel = $null; Band = '' }
    } elseif ($cur -and $line -match '^\s+Signal\s*:\s*(\d+)\s*%') {
        $cur.Signal = [int]([int]$Matches[1] / 2 - 100)   # Prozent -> ca. dBm
    } elseif ($cur -and $line -match '^\s+(Kanal|Channel)\s*:\s*(\d+)') {
        $cur.Channel = [int]$Matches[2]
    } elseif ($cur -and $line -match '^\s+Band\s*:\s*(.+)$') {
        $cur.Band = $Matches[1].Trim()
    }
}
if ($cur) { $nets += $cur }
$nets = $nets | Where-Object { $_.Channel -and $_.Signal -ne $null }

if (-not $nets) { Write-Host "Keine WLANs gefunden."; exit 1 }

function Get-Rating([int]$s) {
    if ($s -ge -50) { 'ausgezeichnet' } elseif ($s -ge -60) { 'gut' } elseif ($s -ge -67) { 'ausreichend' }
    elseif ($s -ge -75) { 'schwach' } else { 'sehr schwach' }
}
function Get-Weight([int]$s) { [math]::Max(0, $s + 100) }

$is6 = { param($n) $n.Band -match '^6' }
$net24 = $nets | Where-Object { $_.Channel -le 14 -and -not (& $is6 $_) }
$net5  = $nets | Where-Object { $_.Channel -ge 32 -and -not (& $is6 $_) }
$net6  = $nets | Where-Object { & $is6 $_ }

function Show-Table($list) {
    if (-not $list) { Write-Host '  (keine Netze)'; return }
    $list | Group-Object Channel | Sort-Object { [int]$_.Name } | ForEach-Object {
        $best = ($_.Group | Measure-Object Signal -Maximum).Maximum
        $dfs = if ([int]$_.Name -ge 52 -and [int]$_.Name -le 144 -and $_.Group[0].Band -notmatch '^6') { '  [DFS]' } else { '' }
        '{0,3}     {1,4}   {2} dBm ({3}){4}' -f $_.Name, $_.Count, $best, (Get-Rating $best), $dfs
    } | Write-Host
}

Write-Host ("{0} WLAN(s) gefunden." -f @($nets).Count)

Write-Host "`n== 2,4 GHz ==" -ForegroundColor Cyan
Write-Host 'Kanal   Netze  stärkstes Signal'
Show-Table $net24
$scores = @{}
foreach ($k in 1, 6, 11) {
    $scores[$k] = ($net24 | Where-Object { [math]::Abs($_.Channel - $k) -lt 5 } |
                   ForEach-Object { Get-Weight $_.Signal } | Measure-Object -Sum).Sum
    if (-not $scores[$k]) { $scores[$k] = 0 }
}
$best24 = (1, 6, 11 | Sort-Object { $scores[$_] } | Select-Object -First 1)
Write-Host ("Störwert:  Kanal 1 = {0},  Kanal 6 = {1},  Kanal 11 = {2}  (kleiner ist besser)" -f $scores[1], $scores[6], $scores[11])
Write-Host ("Empfehlung 2,4 GHz: Kanal {0}, Kanalbreite 20 MHz" -f $best24) -ForegroundColor Green
$bad = @($net24 | Where-Object { $_.Channel -notin 1, 6, 11 }).Count
if ($bad) { Write-Host ("Hinweis: {0} Netz(e) nutzen überlappende Kanäle (nicht 1/6/11) und stören zusätzlich." -f $bad) }

Write-Host "`n== 5 GHz ==" -ForegroundColor Cyan
Write-Host 'Kanal   Netze  stärkstes Signal'
Show-Table $net5
$s5 = @{}
foreach ($k in 36, 40, 44, 48) {
    $sum = 0
    foreach ($n in $net5) {
        if ($n.Channel -eq $k) { $sum += Get-Weight $n.Signal }
        elseif ($n.Channel -ge 36 -and $n.Channel -le 48) { $sum += (Get-Weight $n.Signal) / 2 }
    }
    $s5[$k] = $sum
}
$best5 = (36, 40, 44, 48 | Sort-Object { $s5[$_] } | Select-Object -First 1)
$free = if ($s5[$best5] -eq 0) { ' – völlig frei' } else { '' }
$width = if ($s5[$best5] -gt 150) { ' (oder 40 MHz bei vielen Nachbarn)' } else { '' }
Write-Host ("Empfehlung 5 GHz: Kanal {0} (ohne DFS){1}, Kanalbreite 80 MHz{2}" -f $best5, $free, $width) -ForegroundColor Green
$freeBlocks = foreach ($b in 52, 100, 116, 132) {
    $used = $net5 | Where-Object { $_.Channel -ge $b -and $_.Channel -le $b + 12 }
    if (-not $used) { "$b-$($b + 12)" }
}
if ($freeBlocks) {
    Write-Host ("Alternative: freie DFS-Blöcke {0} (kann kurze Unterbrechungen durch Radarerkennung verursachen)" -f ($freeBlocks -join ', '))
}

if ($net6) {
    Write-Host "`n== 6 GHz ==" -ForegroundColor Cyan
    Write-Host 'Kanal   Netze  stärkstes Signal'
    Show-Table $net6
}
