---
type: Module Overview
title: PSmac Quickstart
description: PSmac is a PowerShell 7.4+ module for macOS that wraps native macOS commands into PowerShell-friendly cmdlets for app management, network info, and system utilities.
resource: https://github.com/the-mentor/PSmac
tags: [powershell, macos, module, psframework]
---

# PSmac Quickstart

## What is PSmac?

PSmac ("PowerShell for macOS") is a PowerShell module that provides macOS-optimized cmdlets for everyday tasks — launching and stopping applications, inspecting network and routing tables, and emptying the Trash. It wraps native macOS commands (`open`, `osascript`, `netstat`) and PowerShell cmdlets (`Get-Process`, `Get-ChildItem`) behind PowerShell functions with tab-completion and validation.

**Key facts:**
- **Version:** 1.0.0 (initial release, March 2026)
- **Author:** Avri Chen-Roth
- **PowerShell requirement:** 7.4+ (Core edition only)
- **Platform:** macOS (warns on import if not on macOS)
- **Published to:** [PSGallery](https://github.com/the-mentor/PSmac)

## Installation

```powershell
Install-Module -Name 'PSmac' -Scope CurrentUser
```

## Public Commands

| Command | Description |
|---|---|
| `Get-MacOSApp` | Lists `.app` bundles from `/Applications` and `~/Applications`, optionally filtered by name |
| `Start-MacOSApp` | Launches an app by name using `open -a` |
| `Stop-MacOSApp` | Stops a running process by name |
| `Restart-MacOSApp` | Stops then relaunches an app (stop → 1s sleep → open) |
| `Get-MacOSNetworkInfo` | Parses `netstat -in` into structured objects (interface, MTU, packets, errors) |
| `Get-MacOSRoutingInfo` | Parses `netstat -rn` into structured routing table objects |
| `Empty-MacOSTrash` | Empties the macOS Trash via `osascript` (Finder) |

See [Functions](functions.md) for detailed behavior, parameters, and the argument-completer pattern shared by all commands.

## Architecture

The module uses a dot-sourcing loader (`PSmac.psm1`) that imports internal functions, public functions, and initialization scripts at import time. During CI builds, all `.ps1` files are compiled into a single flat `.psm1` for publication. The [architecture page](architecture.md) covers the loading flow, the initialization script (brew shellenv, completions), and the build/publish process.

## CI and Testing

PSmac uses a PSFramework-based build pipeline with Pester tests for file integrity, manifest validation, help quality, and PSScriptAnalyzer rule compliance. CI runs on `windows-latest` with two workflows: `build.yml` (push to main/master) and `validate.yml` (pull requests). The [CI & Testing page](ci-testing.md) covers the pipeline steps, test categories, and the banned-commands policy. Note that the CI validate step currently has its Pester call commented out, so the suite runs locally only — see [CI & Testing](ci-testing.md) for details.

## Backlog

- **Re-enable Pester in CI:** the validate step (`build/vsts-validate.ps1`) has its Pester invocation commented out, so tests do not run in CI. See [CI & Testing](ci-testing.md).
- **PlatyPS help generation:** `Microsoft.PowerShell.PlatyPS` is installed as a build prerequisite but no generated help files exist yet. Document when help content is added.
- **internal/functions:** Currently empty — no internal (non-exported) functions to document.