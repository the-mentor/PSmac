---
type: Function Reference
title: PSmac Public Functions
description: Reference for all seven exported PSmac cmdlets — app lifecycle (Get/Start/Stop/Restart-MacOSApp), network info (Get-MacOSNetworkInfo, Get-MacOSRoutingInfo), and system utility (Empty-MacOSTrash) — including parameters, validation, and the shared argument-completer pattern.
resource: https://github.com/the-mentor/PSmac/tree/main/PSmac/functions
tags: [powershell, cmdlets, macos, argument-completer]
---

# Public Functions

PSmac exports seven functions from `PSmac/functions/`. Each function lives in its own `.ps1` file named after the function. All functions follow a shared pattern of `[ValidateScript]` + `[ArgumentCompleter]` for tab-completion and input validation.

## App Lifecycle Functions

These four functions form a lifecycle group: `Get-MacOSApp` discovers installed apps, `Start-MacOSApp` launches them, `Stop-MacOSApp` terminates running processes, and `Restart-MacOSApp` combines stop+start.

### Get-MacOSApp

Lists `.app` bundles from `/Applications` and `~/Applications`.

- **Parameter:** `-AppName` (optional, positional) — filter by app name (without `.app` extension)
- **Validation:** `[ValidateScript]` checks the name exists in the discovered `.app` list
- **Tab completion:** `[ArgumentCompleter]` lists all `.app` names matching the typed prefix, quoting names with spaces
- **Output:** Custom objects with `Name` (extension stripped) and `FullName` properties
- **Source:** `PSmac/functions/Get-MacOSApp.ps1`

```powershell
Get-MacOSApp                    # List all installed apps
Get-MacOSApp -AppName Safari    # Get a specific app
```

### Start-MacOSApp

Launches an application using the macOS `open -a` command.

- **Parameter:** `-AppName` (mandatory, positional) — app name to launch
- **Validation:** Same `[ValidateScript]` pattern as `Get-MacOSApp` — must exist in `/Applications` or `~/Applications`
- **Tab completion:** Lists installed `.app` names matching the prefix
- **Behavior:** Calls `open -a "$AppName"`
- **Source:** `PSmac/functions/Start-MacOSApp.ps1`

### Stop-MacOSApp

Stops a running process by name.

- **Parameter:** `-AppName` (mandatory, positional) — process name to stop
- **Validation:** `[ValidateScript]` checks the name exists in `(Get-Process).Name` — i.e., the process must currently be running
- **Tab completion:** Lists running process names matching the prefix
- **Behavior:** `Get-Process $AppName | Stop-Process`
- **Source:** `PSmac/functions/Stop-MacOSApp.ps1`

### Restart-MacOSApp

Stops a running process and relaunches it.

- **Parameter:** `-AppName` (mandatory, positional) — process name to restart
- **Validation:** Same as `Stop-MacOSApp` — must be a running process
- **Behavior:** `Get-Process $AppName | Stop-Process` → `Start-Sleep -Seconds 1` → `open -a "$AppName"`
- **Source:** `PSmac/functions/Restart-MacOSApp.ps1`

> **Note:** `Restart-MacOSApp` validates against running processes (like `Stop-MacOSApp`), not installed apps. If an app is installed but not running, restart will fail validation. The 1-second sleep between stop and start is hardcoded.

## Network Info Functions

### Get-MacOSNetworkInfo

Parses `netstat -in` output into structured objects.

- **No parameters**
- **Behavior:** Runs `netstat -in`, splits output by newlines, parses each line into columns
- **Output:** Array of `PSCustomObject` with properties: `Name`, `Mtu`, `Network`, `Address`, `Ipkts`, `Ierrs`, `Opkts`, `Oerrs`, `Coll`
- **Source:** `PSmac/functions/Get-MacOSNetworkInfo.ps1`

> **Caveat:** The parser splits on `\s+` and uses fixed column indices (0-8). Lines with fewer columns (e.g., summary rows) may produce `$null` values. The loop starts at index 1, skipping the header row.

### Get-MacOSRoutingInfo

Parses `netstat -rn` output into structured routing table objects.

- **No parameters**
- **Behavior:** Runs `netstat -rn`, skips header, detects section markers (`Internet:`, `Internet6:`), parses route lines
- **Output:** Array of `PSCustomObject` with properties: `Section` (Internet/Internet6), `Destination`, `Gateway`, `Flags`, `Netif`, `Expire`
- **Source:** `PSmac/functions/Get-MacOSRoutingInfo.ps1`

> **Caveat:** The parser skips blank lines and column-header lines via regex. The `Expire` field is `$null` when the line has fewer than 5 columns (which is common for many routes).

## System Utility Functions

### Empty-MacOSTrash

Empties the macOS Trash.

- **No parameters**
- **Behavior:** Calls `osascript -e 'try' -e 'tell application "Finder" to empty' -e 'end try'`
- **Source:** `PSmac/functions/Empty-MacOSTrash.ps1`

The `try/end try` wrapping suppresses errors if the Finder is busy or the Trash is already empty. This approach was sourced from [Super User](https://superuser.com/questions/1877663).

## Shared Argument-Completer Pattern

All app-lifecycle functions use a common pattern for parameter validation and tab completion:

1. **`[ValidateScript]`** — validates the input against a live query (installed apps or running processes). Returns `$true` if the value is in the allowed list.
2. **`[ArgumentCompleter]`** — provides tab completion by executing the same query and filtering by the `$wordToComplete` prefix.

The validation and completion logic is duplicated within each function (the `[ValidateScript]` script block and the `[ArgumentCompleter]` script block contain the same query). This is a known pattern tradeoff — PowerShell does not allow sharing code between these attributes at declaration time. See [architecture](architecture.md) for how these files are compiled at build time.

## Error Messages

All `[ValidateScript]` attributes use the same generic error message: `"Please specify the name of a subdirectory in the current directory."` — this appears to be a template artifact that doesn't accurately describe the validation being performed. Future improvements could customize these messages per function.