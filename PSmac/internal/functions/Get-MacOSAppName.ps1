function Get-MacOSAppName {
    (Get-ChildItem -Path @("/Applications", "~/Applications") -Filter *.app | Select-Object @{l = "Name"; e = { $_.name.Replace('.app', '') } }).Name
}
