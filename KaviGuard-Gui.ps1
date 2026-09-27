# KaviGuard GUI dashboard - double-click the desktop icon to open.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "SilentlyContinue"
$script:dir     = "C:\Tools\KaviGuard"
$script:watcher = Join-Path $script:dir "KaviGuard.ps1"
$script:ico     = Join-Path $script:dir "kaviguard.ico"

$bg     = [System.Drawing.Color]::FromArgb(24, 28, 36)
$panelc = [System.Drawing.Color]::FromArgb(34, 40, 52)
$btnc   = [System.Drawing.Color]::FromArgb(48, 54, 68)
$green  = [System.Drawing.Color]::FromArgb(63, 185, 80)
$red    = [System.Drawing.Color]::FromArgb(248, 81, 73)
$fg     = [System.Drawing.Color]::FromArgb(230, 237, 243)
$dim    = [System.Drawing.Color]::FromArgb(139, 148, 158)

function Get-KGData {
    $f = Join-Path $script:dir "status.json"
    if (Test-Path $f) { try { return (Get-Content $f -Raw | ConvertFrom-Json) } catch {} }
    return $null
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "KaviGuard"
$form.Size = New-Object System.Drawing.Size(460, 560)
$form.StartPosition = "CenterScreen"
$form.BackColor = $bg
$form.ForeColor = $fg
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false
if (Test-Path $script:ico) { try { $form.Icon = New-Object System.Drawing.Icon($script:ico) } catch {} }

$pic = New-Object System.Windows.Forms.PictureBox
$pic.Location = New-Object System.Drawing.Point(24, 18)
$pic.Size = New-Object System.Drawing.Size(72, 72)
$pic.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
if (Test-Path $script:ico) { try { $pic.Image = [System.Drawing.Image]::FromFile($script:ico) } catch {} }
$form.Controls.Add($pic)

$title = New-Object System.Windows.Forms.Label
$title.Location = New-Object System.Drawing.Point(112, 20)
$title.Size = New-Object System.Drawing.Size(300, 42)
$title.Text = "KaviGuard"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = $fg
$form.Controls.Add($title)

$verLbl = New-Object System.Windows.Forms.Label
$verLbl.Location = New-Object System.Drawing.Point(114, 62)
$verLbl.Size = New-Object System.Drawing.Size(300, 24)
$verLbl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$verLbl.ForeColor = $dim
$form.Controls.Add($verLbl)

$statusLbl = New-Object System.Windows.Forms.Label
$statusLbl.Location = New-Object System.Drawing.Point(24, 106)
$statusLbl.Size = New-Object System.Drawing.Size(400, 38)
$statusLbl.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($statusLbl)

$rows = New-Object System.Windows.Forms.Panel
$rows.Location = New-Object System.Drawing.Point(24, 150)
$rows.Size = New-Object System.Drawing.Size(400, 224)
$rows.BackColor = $panelc
$form.Controls.Add($rows)

$script:valLbls = @{}
$fields = @(
    @("started", "Watching since"),
    @("quick",   "Last quick scan"),
    @("full",    "Last full scan"),
    @("found",   "Threats found"),
    @("quar",    "Threats quarantined"),
    @("rt",      "Defender real-time"),
    @("qfiles",  "Files in quarantine")
)
$y = 12
foreach ($fld in $fields) {
    $cap = New-Object System.Windows.Forms.Label
    $cap.Location = New-Object System.Drawing.Point(14, $y)
    $cap.Size = New-Object System.Drawing.Size(150, 22)
    $cap.Text = $fld[1]
    $cap.ForeColor = $dim
    $cap.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $rows.Controls.Add($cap)
    $v = New-Object System.Windows.Forms.Label
    $v.Location = New-Object System.Drawing.Point(170, $y)
    $v.Size = New-Object System.Drawing.Size(216, 22)
    $v.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $v.ForeColor = $fg
    $rows.Controls.Add($v)
    $script:valLbls[$fld[0]] = $v
    $y += 28
}

$script:note = New-Object System.Windows.Forms.Label
$script:note.Location = New-Object System.Drawing.Point(24, 384)
$script:note.Size = New-Object System.Drawing.Size(400, 26)
$script:note.ForeColor = $dim
$script:note.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$form.Controls.Add($script:note)

function Update-KGGui {
    $s = Get-KGData
    if ($s -and $s.running) {
        $statusLbl.Text = "PROTECTED"
        $statusLbl.ForeColor = $green
    } else {
        $statusLbl.Text = "NOT RUNNING"
        $statusLbl.ForeColor = $red
    }
    $verLbl.Text = if ($s) { "version $($s.version)" } else { "version ?" }
    $L = $script:valLbls
    $L["started"].Text = if ($s -and $s.startedAt) { "$($s.startedAt)" } else { "-" }
    $L["quick"].Text   = if ($s -and $s.lastQuickScan) { "$($s.lastQuickScan)" } else { "not yet" }
    $L["full"].Text    = if ($s -and $s.lastFullScan) { "$($s.lastFullScan)" } else { "not yet" }
    $fnd = 0; $qrn = 0
    if ($s) { $fnd = [int]$s.threatsFound; $qrn = [int]$s.threatsQuarantined }
    $L["found"].Text = "$fnd"
    $L["found"].ForeColor = if ($fnd -gt 0) { $red } else { $fg }
    $L["quar"].Text = "$qrn"
    $L["quar"].ForeColor = if ($qrn -gt 0) { $red } else { $fg }
    if ($s -and $s.defenderRealtime -eq $true) { $L["rt"].Text = "ON"; $L["rt"].ForeColor = $green }
    else { $L["rt"].Text = "OFF"; $L["rt"].ForeColor = $red }
    $qn = @(Get-ChildItem (Join-Path $script:dir "quarantine") -File -ErrorAction SilentlyContinue).Count
    $L["qfiles"].Text = "$qn"
}

function Add-KGButton($text, $x, $y, $w, $action) {
    $b = New-Object System.Windows.Forms.Button
    $b.Location = New-Object System.Drawing.Point($x, $y)
    $b.Size = New-Object System.Drawing.Size($w, 34)
    $b.Text = $text
    $b.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $b.FlatAppearance.BorderColor = $dim
    $b.BackColor = $btnc
    $b.ForeColor = $fg
    $b.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $b.Add_Click($action)
    $form.Controls.Add($b)
}

$scanBase = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script:watcher`""
Add-KGButton "Quick Scan" 24 418 120 {
    $script:note.Text = "Starting quick scan - approve the admin prompt..."
    Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList "$scanBase -ScanNow Quick"
    $script:note.Text = "Quick scan running in the background."
}
Add-KGButton "Full Scan" 152 418 120 {
    $script:note.Text = "Starting full scan - approve the admin prompt..."
    Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList "$scanBase -ScanNow Full"
    $script:note.Text = "Full scan running in the background."
}
Add-KGButton "Refresh" 280 418 144 { Update-KGGui; $script:note.Text = "Refreshed." }
Add-KGButton "Open Logs" 24 460 120 { Start-Process (Join-Path $script:dir "logs") }
Add-KGButton "Quarantine" 152 460 120 { Start-Process (Join-Path $script:dir "quarantine") }
Add-KGButton "Close" 280 460 144 { $form.Close() }

Update-KGGui
[void]$form.ShowDialog()
