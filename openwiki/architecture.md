---
type: Architecture
title: PSmac Module Architecture
description: PSmac uses a dot-sourcing loader that imports internal functions, public functions, and initialization scripts; CI builds compile all .ps1 files into a single flat .psm1 for publication to PSGallery.
resource: https://github.com/the-mentor/PSmac/blob/main/PSmac/PSmac.psm1
tags: [powershell, module-loader, build, psframework]
---

# Module Architecture

## Module Loading (Development)

In the source tree, `PSmac/PSmac.psm1` is a dot-sourcing loader that imports files in a specific order:

1. **Internal functions** — `PSmac/internal/functions/*.ps1` (currently empty; reserved for non-exported helpers)
2. **Public functions** — `PSmac/functions/*.ps1` (the six exported cmdlets)
3. **Initialization scripts** — `PSmac/internal/scripts/*.ps1`

```
PSmac/
├── PSmac.psd1                    # Module manifest
├── PSmac.psm1                    # Dot-sourcing loader
├── functions/                    # Public functions (exported)
│   ├── Start-MacOSApp.ps1
│   ├── Stop-MacOSApp.ps1
│   ├── Restart-MacOSApp.ps1
│   ├── Get-MacOSNetworkInfo.ps1
│   ├── Get-MacOSRoutingInfo.ps1
│   └── Empty-MacOSTrash.ps1
└── internal/
    ├── functions/                # Internal functions (not exported)
    └── scripts/
        ├── intialize.ps1        # Module import-time initialization
        └── variables.ps1        # Module-wide variable definitions
```

The loader itself (`PSmac.psm1`) is straightforward:

```powershell
$script:ModuleRoot = $PSScriptRoot
# Dot-source internal functions, then public functions, then scripts
foreach ($file in Get-ChildItem -Path "$PSScriptRoot/internal/functions" -Filter *.ps1 -Recurse) {
    . $file.FullName
}
foreach ($file in Get-ChildItem -Path "$PSScriptRoot/functions" -Filter *.ps1 -Recurse) {
    . $file.FullName
}
foreach ($file in Get-ChildItem -Path "$PSScriptRoot/internal/scripts" -Filter *.ps1 -Recurse) {
    . $file.FullName
}
```

## Module Manifest

`PSmac/PSmac.psd1` declares:
- **RootModule:** `PSmac.psm1`
- **ModuleVersion:** `1.0.0`
- **CompatiblePSEditions:** `Core` (PowerShell 7+ only)
- **PowerShellVersion:** `7.4`
- **FunctionsToExport:** `@('*')` — all public functions are exported (the build process replaces this with an explicit list)
- **GUID:** `d7b62bfc-b27f-4ce6-a8e3-b823b5628a2b`

## Initialization Script

`internal/scripts/intialize.ps1` (note the original typo in the filename) runs at import time:

1. **Platform check** — warns if not on macOS: `"This module is only supported on macOS."`
2. **Brew initialization** — if `/opt/homebrew/bin/brew` exists, runs `brew shellenv | Invoke-Expression` to put Homebrew binaries on PATH
3. **Brew completions** — if brew is available and `$(brew --prefix)/share/pwsh/completions` exists, dot-sources all completion files

`internal/scripts/variables.ps1` is a placeholder for module-wide variables (currently has no production variables defined).

## Build Process (Compiled .psm1)

During CI, `build/psf-build.ps1` transforms the multi-file development layout into a single-file published module:

1. Creates a `publish/` directory and copies `PSmac/` into it
2. Concatenates all `.ps1` file contents (internal functions → public functions → scripts) into a single `PSmac.psm1`, prefixed with `$script:ModuleRoot = $PSScriptRoot`
3. Appends an explicit `Export-ModuleMember -Function '...'` statement listing all public function names
4. Deletes the `internal/` and `functions/` directories from the publish output
5. **Auto-versions** (if `AutoVersion` is enabled in `config.psd1`): queries the PSGallery for the latest published version and increments the build number
6. **Explicit function export** (if `ExportFunctions` is enabled): updates the manifest's `FunctionsToExport` with the sorted list of public function names

### config.psd1

The build configuration file at the repo root controls three flags:

| Flag | Default | Effect |
|---|---|---|
| `AutoVersion` | `$true` | Automatically increments the module version's build number based on the latest PSGallery release |
| `ExportFunctions` | `$true` | Automatically populates `FunctionsToExport` in the manifest from `functions/*.ps1` filenames |
| `GithubRelease` | `$true` | Creates a GitHub release with the built module zip as an asset |

## Two Build Tool Variants

The repo carries two parallel sets of build scripts:

| Variant | Scripts | Package Manager | Used By |
|---|---|---|---|
| **PSFramework** | `build/psf-*.ps1` | PSFramework.NuGet / `Publish-PSFModule` | Active CI (`build.yml`) |
| **VSTS/PowerShellGet** | `build/vsts-*.ps1` | PowerShellGet / `Publish-Module` | Legacy Azure DevOps pipelines |

Both follow the same compile-then-publish pattern. The PSFramework variant is used in the current GitHub Actions workflow. See [CI & Testing](ci-testing.md) for how these scripts are invoked.

## Relationship to Functions

Each public function in `functions/` is a standalone `.ps1` file that defines a single PowerShell function. The [functions reference](functions.md) documents each command's behavior, parameters, and the shared argument-completer pattern. At build time, these files are concatenated into the published `.psm1`.