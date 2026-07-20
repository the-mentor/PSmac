function Get-MacOSProcessName {
    (Get-Process).Name | Where-Object { $_ }
}
