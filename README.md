# KaviGuard v1.4.0

A lightweight Windows malware watcher. It does not replace Windows Defender —
Defender stays the engine. KaviGuard is a watchdog + orchestrator around it:

- **File watcher** — watches Downloads, Desktop, and TEMP. When a new
  executable-type file appears (`.exe`, `.msi`, `.bat`, `.cmd`, `.ps1`,
  `.vbs`, `.js`, `.jse`, `.scr`, `.dll`, `.com`, `.pif`), it:
  1. Hashes it (SHA256) and checks the hash against MalwareBazaar
     (abuse.ch) — known-bad = moved to `C:\Tools\KaviGuard\quarantine`.
  2. Falls back to a Defender scan of the file on any lookup failure.
  3. Files over 500 MB skip the hash/lookup but still get a Defender scan.
  4. Shows a toast only on hits; all results go in the log.
- **Persistence monitor** (every 5 min) — snapshots Run/RunOnce registry keys,
  both Startup folders, scheduled tasks, and services; alerts on anything
  *new*. First run only writes the baseline, no alerts. Toasts say "new
  startup entry, verify it's yours" — it can't know if it's malware.
- **Defender health** (every 15 min) — if real-time protection is off, toasts
  and logs. Never force-enables anything.
- **Scheduled scans** — Defender QuickScan daily (~3 AM), FullScan weekly
  (Sundays ~3 AM), run by the watcher itself. Skips if a scan is already
  running. Toasts only if threats are found; logs start/finish/clean.
- **Self-update** (every 6 h) — checks `version.txt` at the configured
  `$UpdateBaseUrl`; downloads new versions of the engine, the dashboard, AND
  the mailbox poller (each with its SHA256), verifies every hash AND parses
  every file for syntax errors before replacing anything, then restarts via
  the scheduled task. Features and design update together. Anything failing =
  log only, never a broken update.
- **Mailbox poller** (every 15 min, task `KaviGuard-Mailbox`) — signs in to
  Gmail over IMAP with an app password (DPAPI-encrypted on the PC, never
  leaves it), reads the `kavi-mail` label for `[kavi-mail] to:kaviguard`
  command mail, runs a strict command whitelist (STATUS, VERSION, LOG,
  SCAN QUICK/FULL/PATH, TUNEUP, EXCLUDE ADD/REMOVE — never executes mail content), emails
  the result back to `kavi-mail`, archives the command. Lets every Kavi drive
  KaviGuard with zero AI on the PC side. Installer: `Install-MailboxPoller.ps1`.

## What it does NOT do

- Not an antivirus. Windows Defender + its real-time protection is the engine.
- Quarantine means **move to the quarantine folder, never delete**.
- Never disables or weakens Defender. Never force-enables anything.
- Never touches network/firewall/tunnel configuration. **Hard rule:**
  Tailscale and the Mesh Agent are infrastructure. KaviGuard protects them —
  it never fights them, never flags them, never changes their config.
- No outbound data except: MalwareBazaar hash lookups and update checks.
  No telemetry.

## Files / logs

- Script: `C:\Tools\KaviGuard\KaviGuard.ps1`
- Quarantine: `C:\Tools\KaviGuard\quarantine\`
- Logs: `C:\Tools\KaviGuard\logs\kaviguard.log` (and `*.old` when rotated at 5 MB)
- Baseline: `C:\Tools\KaviGuard\persistence-baseline.json`
- Scan state: `C:\Tools\KaviGuard\scanstate.json`
- Agent status: `C:\Tools\KaviGuard\status.json` (rewritten every minute)
- Runtime-added exclusions: `C:\Tools\KaviGuard\extra-exclusions.json`
- Status dashboard: `C:\Tools\KaviGuard\Show-Status.ps1` (text fallback)
- GUI dashboard: `C:\Tools\KaviGuard\KaviGuard-Gui.ps1` (the desktop icon runs this: dark window, shield icon, big PROTECTED status, Quick/Full Scan buttons, Tune-Up + Scan File buttons, log + quarantine shortcuts)
- Startup splash: a "KaviGuard active" toast pops at every logon/boot so you know the watcher is up
- Task: `KaviGuard` in Task Scheduler (logon trigger, hidden, restarts on failure)

## Agent integration (for Kavi agents)

Any Kavi agent can check on and drive KaviGuard — no remote desktop needed,
just a paste on Seth's PC (or ask Seth to paste):

- **Status:** `powershell -File C:\Tools\KaviGuard\KaviGuard.ps1 -Status`
  prints `status.json`: version, running, startedAt, lastQuickScan,
  lastFullScan, threatsFound, threatsQuarantined, defenderRealtime,
  exclusionCount, lastUpdateCheck, lastError.
- **Scan now:** `-ScanNow Quick` or `-ScanNow Full` — triggers a Defender
  scan immediately (skips if one is already running), logs the results.
- **Exclusions:** `-AddExclusion "C:\path\to\folder"` /
  `-RemoveExclusion "C:\path\to\folder"` — persisted in
  `extra-exclusions.json` so they survive self-updates; also applied to
  Defender when run as Admin.
- **Logs:** `C:\Tools\KaviGuard\logs\kaviguard-YYYY-MM-DD.log` — one line per
  event, plain text, safe to paste back for diagnosis.
- **Quarantine:** `C:\Tools\KaviGuard\quarantine\` — files are moved here,
  never deleted. Review before restoring anything.

Rules: manage KaviGuard through these interfaces only. Never kill its
scheduled task, never hand-edit its files while it's running, and never add
an exclusion for a folder you don't recognize — excluded folders are blind
spots for both KaviGuard and Defender.

## Config (top of the script)

Times, scan day, hash size cap, MalwareBazaar URL, update URL — all editable
in the config block at the top of `KaviGuard.ps1`.

**Exclusions (blind spots — read this):**

```powershell
$ExcludePaths = @(
    "$env:USERPROFILE\rvd",
    "$env:USERPROFILE\rvg13",
    "$env:USERPROFILE\rvg14",
    "$env:USERPROFILE\Desktop\RVG-v1.2-rollback",
    "C:\Tools\KaviGuard",
    "C:\Users\sethr\kavi-mail"
)
$ExcludeFileNames = @("tailscale.exe", "meshagent.exe", "rvg_agent.exe", "rvg_viewer.py")
```

The file watcher skips these paths entirely, and the installer adds them as
Defender exclusions (`Add-MpPreference -ExclusionPath`, plus `-ExclusionProcess`
for the service executables). These are my agent projects and remote-access
tooling — they must never be interfered with.

**The tradeoff, stated plainly:** malware placed inside an excluded folder is
invisible to KaviGuard and to Defender's scans. That's the price of keeping
the tools working. Don't download random files into these folders, and if one
ever acts strangely, run a manual Defender full scan of it.

**Persistence whitelist:** `$KnownGoodTasks` in config lists the Tailscale
service, Mesh Agent service, the `RVG agent` logon task, and the
`RVG update check` daily task. The persistence monitor never alerts on them —
they're infrastructure, not suspects.

## Updates

Self-updates from `$UpdateBaseUrl` (`https://raw.githubusercontent.com/kellner-dot/kaviguard/main`).
To publish an update: edit the scripts, bump `version.txt`, post the new
files and their SHA256s (`KaviGuard.ps1` + `.sha256`, `KaviGuard-Gui.ps1` +
`.sha256`, `KaviGuard-Mailbox.ps1` + `.sha256`). PCs pick it up within 6 hours —
engine, dashboard design, and mailbox poller all update together.

## Uninstall

Paste in Admin PowerShell:

```powershell
Unregister-ScheduledTask -TaskName KaviGuard -Confirm:$false
Remove-MpPreference -ExclusionPath 'C:\Tools\KaviGuard'
Remove-MpPreference -ExclusionProcess 'C:\Program Files\Tailscale\tailscale.exe'
Remove-MpPreference -ExclusionProcess 'C:\Program Files\Mesh Agent\meshagent.exe'
Remove-Item 'C:\Tools\KaviGuard' -Recurse -Force
```

(Also remove the project-path exclusions from Windows Security > Virus &
threat protection > Manage settings > Exclusions if you want them gone.)
