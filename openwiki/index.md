---
okf_version: "0.1"
---

# Files

- [PSmac Module Architecture](architecture.md) - PSmac uses a dot-sourcing loader that imports internal functions, public functions, and initialization scripts; CI builds compile all .ps1 files into a single flat .psm1 for publication to PSGallery.
- [PSmac CI & Testing](ci-testing.md) - PSmac uses GitHub Actions (build.yml on push, validate.yml on PR, openwiki-update.yml on schedule) and a PSFramework-style Pester suite covering file integrity, manifest validity, help quality, and PSScriptAnalyzer rules, with a banned-commands policy enforced during file-integrity checks.
- [PSmac Public Functions](functions.md) - Reference for all six exported PSmac cmdlets — app lifecycle (Start/Stop/Restart-MacOSApp), network info (Get-MacOSNetworkInfo, Get-MacOSRoutingInfo), and system utility (Empty-MacOSTrash) — including parameters, validation, and the shared argument-completer pattern.
- [PSmac Quickstart](quickstart.md) - PSmac is a PowerShell 7.4+ module for macOS that wraps native macOS commands into PowerShell-friendly cmdlets for app management, network info, and system utilities.
