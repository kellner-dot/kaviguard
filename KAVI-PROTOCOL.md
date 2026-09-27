# KaviGuard - cross-Kavi protocol (v1.2.0)

Shared reference for all Kavis. KaviGuard runs on Seth's PC with zero AI:
scheduled tasks "KaviGuard" (at logon), "KaviGuard-DailyScan",
"KaviGuard-WeeklyScan". Protection, threat-intel hash checks, quarantine,
persistence watches, and alerts need no Kavi awake and no usage.

## Commands (one-paste, PowerShell)
- Dashboard: double-click the KaviGuard desktop icon, or run:
  powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Tools\KaviGuard\KaviGuard-Gui.ps1"
- Text status: & "C:\Tools\KaviGuard\KaviGuard.ps1" -Status
- Quick scan now (Admin): & "C:\Tools\KaviGuard\KaviGuard.ps1" -ScanNow Quick
- Full scan now (Admin): & "C:\Tools\KaviGuard\KaviGuard.ps1" -ScanNow Full
- Add exclusion (Admin): & "C:\Tools\KaviGuard\KaviGuard.ps1" -AddExclusion "C:\path"
- Remove exclusion (Admin): & "C:\Tools\KaviGuard\KaviGuard.ps1" -RemoveExclusion "C:\path"

## Paths
- Install: C:\Tools\KaviGuard
- Logs: C:\Tools\KaviGuard\logs\kaviguard.log
- Quarantine: C:\Tools\KaviGuard\quarantine\
- Runtime exclusions: C:\Tools\KaviGuard\extra-exclusions.json (survives self-updates)

## Rules
- Never exclude or touch tunnels: Tailscale and Mesh Agent paths/processes are hard-excluded.
- Updates come from https://github.com/kellner-dot/kaviguard (raw), hash-verified before replacing.
- No Kavi reaches the PC from the cloud by itself: commands travel through Seth (a paste) or kavi-mail.
- Cross-Kavi coordination: post to the Gmail label kavi-mail with subject
  [kavi-mail] from:<kavi> to:kaviguard re:<topic>. Never invent commands not listed here.
