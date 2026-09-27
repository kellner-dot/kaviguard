# KaviGuard - cross-Kavi protocol (v1.3.0)

Shared reference for all Kavis. KaviGuard runs on Seth's PC with zero AI:
scheduled tasks "KaviGuard" (at logon), "KaviGuard-DailyScan",
"KaviGuard-WeeklyScan", and "KaviGuard-Mailbox" (every 15 min, once the
mailbox poller is installed). Protection, threat-intel hash checks,
quarantine, persistence watches, and alerts need no Kavi awake and no usage.

## Mailbox commands (no paste needed - any Kavi sends an email)
To: his Gmail. Subject: `[kavi-mail] from:<kavi> to:kaviguard re:<topic>`
Body (plain text):
```
COMMAND: STATUS
```
Valid commands: STATUS, VERSION, LOG, SCAN QUICK, SCAN FULL, EXCLUDE ADD,
EXCLUDE REMOVE. EXCLUDE commands need a second line: `ARG: C:\path\to\dir`.
The poller runs the command within ~15 minutes and emails the result back to
the kavi-mail label as `[kavi-mail] from:kaviguard to:<kavi> re:<topic> result`.
Only mail FROM his own Gmail addresses is honored; everything else is ignored.

## One-paste commands (PowerShell, through Seth)
- Dashboard: double-click the KaviGuard desktop icon, or run:
  powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Tools\KaviGuard\KaviGuard-Gui.ps1"
- Text status: & "C:\Tools\KaviGuard\KaviGuard.ps1" -Status
- Quick scan now (Admin): & "C:\Tools\KaviGuard\KaviGuard.ps1" -ScanNow Quick
- Full scan now (Admin): & "C:\Tools\KaviGuard\KaviGuard.ps1" -ScanNow Full
- Add exclusion (Admin): & "C:\Tools\KaviGuard\KaviGuard.ps1" -AddExclusion "C:\path"
- Remove exclusion (Admin): & "C:\Tools\KaviGuard\KaviGuard.ps1" -RemoveExclusion "C:\path"

## Paths
- Install: C:\Tools\KaviGuard
- Logs: C:\Tools\KaviGuard\logs\kaviguard.log and logs\mailbox.log
- Quarantine: C:\Tools\KaviGuard\quarantine\
- Runtime exclusions: C:\Tools\KaviGuard\extra-exclusions.json (survives self-updates)
- Mailbox poller: C:\Tools\KaviGuard\mailbox\ (config.json + DPAPI-encrypted cred.bin)

## Rules
- Never exclude or touch tunnels: Tailscale and Mesh Agent paths/processes are hard-excluded.
- Auto-update (every 6h) covers features AND design: KaviGuard.ps1 (engine),
  KaviGuard-Gui.ps1 (dashboard), and KaviGuard-Mailbox.ps1 (poller). Each file
  is hash-verified and syntax-checked before anything is replaced.
  Source: https://github.com/kellner-dot/kaviguard (raw).
- No Kavi reaches the PC from the cloud by itself except through the mailbox
  poller: commands travel through Seth (a paste) or kavi-mail.
- Cross-Kavi coordination: post to the Gmail label kavi-mail with subject
  [kavi-mail] from:<kavi> to:kaviguard re:<topic>. Never invent commands not listed here.
