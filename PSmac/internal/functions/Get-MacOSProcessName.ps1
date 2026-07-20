function Get-MacOSProcessName {
    Get-Process |
        Where-Object { $_.Path -like "/Applications/*" -or $_.Path -like "$HOME/Applications/*" } |
        Select-Object -ExpandProperty Name -Unique
}
