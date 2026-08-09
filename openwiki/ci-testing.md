---
type: CI & Testing
title: PSmac CI & Testing
description: PSmac uses GitHub Actions (build.yml on push, validate.yml on PR, openwiki-update.yml on schedule) and a PSFramework-style Pester suite covering file integrity, manifest validity, help quality, and PSScriptAnalyzer rules, with a banned-commands policy enforced during file-integrity checks.
resource: https://github.com/the-mentor/PSmac/tree/main/tests
tags: [ci, github-actions, pester, psscriptanalyzer, testing, dependabot]
---

# CI & Testing

PSmac ships a PSFramework-derived test suite under `tests/` and three GitHub Actions workflows under `.github/workflows/`. Tests validate module hygiene rather than macOS runtime behavior, because CI runs on Windows where the wrapped macOS commands (`open`, `netstat`, `osascript`) are unavailable.

## GitHub Actions Workflows

The two module pipelines run on `windows-latest` and use `pwsh`. A third workflow, `openwiki-update.yml`, runs on `ubuntu-latest` to maintain this documentation.

| Workflow | Trigger / Runner | Steps |
|---|---|---|
| `build.yml` | push to `master` or `main` / `windows-latest` | prerequisites → validate → build → publish → release |
| `validate.yml` | `pull_request` / `windows-latest` | prerequisites → validate |
| `openwiki-update.yml` | schedule (`0 8 * * *`) + `workflow_dispatch` / `ubuntu-latest` | check out → install Node 22 → `npm install --global openwiki` → `openwiki code --update --print` → open a pull request via `peter-evans/create-pull-request` |

### build.yml
1. **Install Prerequisites** — `build/psf-prerequisites.ps1`
2. **Validate** — `build/vsts-validate.ps1`
3. **Build** — `build/psf-build.ps1` (compiles the multi-file module into a single `.psm1`; see [architecture](architecture.md))
4. **Publish** — `build/psf-publish.ps1 -ApiKey $env:APIKEY` (publishes to PSGallery via `Publish-PSFModule`; API key from the `ApiKey` secret)
5. **Release** — `build/vsts-release.ps1` (creates a GitHub release using `GITHUB_TOKEN`)

### validate.yml
Runs only the prerequisites and validate steps on pull requests — no build or publish.

> **Accuracy caveat:** `build/vsts-validate.ps1` currently has its Pester invocation **commented out**:
> ```powershell
> # Run internal pester tests
> # & "$PSScriptRoot\..\tests\pester.ps1"
> ```
> As written, the CI "Validate" step is effectively a no-op — the Pester suite below does **not** run automatically in CI today. Uncomment that line (or wire `tests/pester.ps1` into a workflow step) to actually enforce the tests in CI. This is the highest-value change for anyone hardening the pipeline.

### openwiki-update.yml
A scheduled documentation maintenance workflow (distinct from the module pipeline) that runs daily at 08:00 UTC on `ubuntu-latest` and on manual dispatch. It installs the `openwiki` npm package globally on Node 22, runs `openwiki code --update --print` against the repo (using the OpenRouter provider and the `z-ai/glm-5.2` model via the `OPENROUTER_API_KEY` secret), and opens a pull request on the `openwiki/update` branch using `peter-evans/create-pull-request`. The PR scope is limited to `openwiki/`, `AGENTS.md`, and `CLAUDE.md`. This workflow is what produces the wiki you are reading.

### Dependabot
`.github/dependabot.yml` (v2 config) schedules **weekly** updates for the `github-actions` ecosystem, keeping the third-party action versions pinned in the workflows current. All three workflows pin `actions/checkout` to a specific commit SHA (`3d3c42e5aac5ba805825da76410c181273ba90b1`, tagged `v7.0.1`); `openwiki-update.yml` additionally pins `actions/setup-node` (`v7.0.0`) and `peter-evans/create-pull-request` (`v8.1.1`).

## Build Prerequisites

`build/psf-prerequisites.ps1` bootstraps PSFramework.NuGet, then installs:

- **Pester** — test framework
- **PSScriptAnalyzer** — best-practices analyzer used by tests
- **Microsoft.PowerShell.PlatyPS** — help/doc generation (installed but not yet used; see Backlog)
- **PSModuleDevelopment** — module tooling

It also appends any `RequiredModules` declared in the manifest before installing everything via `Install-PSFModule`.

## Test Runner

`tests/pester.ps1` is the entrypoint. It:
1. Imports the module from `PSmac/PSmac.psd1` and `PSmac/PSmac.psm1`.
2. Creates a `TestResults/` folder and writes one JUnit-style XML per test file.
3. Runs **General tests** (`tests/general/*.Tests.ps1`) then **Function tests** (`tests/functions/**/*Tests.ps1`).
4. Throws if any test fails (`"$totalFailed / $totalRun tests failed!"`).

Run locally with:
```powershell
./tests/pester.ps1 -Output Detailed
```

## General Tests

These enforce module-wide policy and are what the suite currently exercises.

### FileIntegrity.Tests.ps1
For every `.ps1` outside `tests/`:
- Must have **UTF-8 with BOM** encoding.
- Must have **no trailing whitespace**.
- Must have **no syntax errors** (parsed via `[System.Management.Automation.Language.Parser]`).
- Must **not use banned commands** (see below).

### PSScriptAnalyzer.Tests.ps1
Runs `Invoke-ScriptAnalyzer` against every function in `PSmac/functions` and `PSmac/internal/functions`, checking each analyzer rule. Excludes `PSAvoidTrailingWhitespace` and `PSShouldProcess`.

### Manifest.Tests.ps1
Validates `PSmac/PSmac.psd1`: the root module and any declared formats/types exist. When `config.psd1`'s `ExportFunctions` is disabled, it also cross-checks that exported functions match the files in `functions/` and that no internal function is exported. Because `ExportFunctions` defaults to `$true`, that export cross-check block is skipped by default. See the manifest details in [architecture](architecture.md).

### Help.Tests.ps1
Evaluates comment-based help for every command (parameter documentation, help content quality), driven by `tests/general/Help.Exceptions.ps1`.

## Banned Commands Policy

`tests/general/FileIntegrity.Exceptions.ps1` defines `$global:BannedCommands` — commands that must not appear in module source, enforced by FileIntegrity.Tests.ps1. These include `Write-Output`, the legacy WMI cmdlets (`Get-WmiObject`, etc.), `Get-EventLog`, user-preference commands (`Clear-Host`, `Set-Location`), the dynamic-variable cmdlets (`Get-/Set-/New-/Clear-/Remove-Variable`), and `Invoke-Expression`.

Per-file exceptions live in `$global:MayContainCommand`; e.g. `Invoke-Expression` is allowed only in `psf-prerequisites.ps1` (which bootstraps PSFramework.NuGet).

## Function Tests

`tests/functions/` currently contains only a README — there are **no unit/integration tests for the six cmdlets** yet. Function-level tests would need to mock or run on macOS since the [public functions](functions.md) shell out to native macOS tools.

## Relationship to Build & Functions

The CI pipeline exercises the build/publish scripts documented in [architecture](architecture.md), and the test suite is designed to validate the [public functions](functions.md) and module hygiene. Today the validate step is disabled, so the tests act as a local-only quality gate until re-enabled.

## Backlog

- **Re-enable Pester in CI** — uncomment the invocation in `build/vsts-validate.ps1` (or add a dedicated test step) so `validate.yml`/`build.yml` actually run the suite.
- **Function tests** — add unit/integration tests under `tests/functions/`.
- **PlatyPS help** — `Microsoft.PowerShell.PlatyPS` is installed but no generated help exists; wire up help generation.
