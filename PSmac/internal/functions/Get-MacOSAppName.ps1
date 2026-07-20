function Get-MacOSAppName {
    (Get-ChildItem -Path @("/Applications", "~/Applications", "/System/Applications") -Filter *.app -Recurse -Depth 1 | Select-Object @{l = "Name"; e = { $_.name.Replace('.app', '') } }).Name
}
