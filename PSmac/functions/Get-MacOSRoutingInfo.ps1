function Get-MacOSRoutingInfo {
    $NetstatInfo = netstat -rn | Select-Object -skip 1
    $lines = $NetstatInfo -split "`n"
    $data
    $section = ""

    $data = foreach ($line in $lines) {
        if ($line -match "^(Internet|Internet6):$") {
            $section = $matches[1]
            continue
        }

        if ($line -match "^(Destination\s+Gateway\s+Flags\s+Netif\s+Expire)$") {
            continue
        }

        if ($line -match "^\s*$") {
            continue
        }

        $columns = $line -split "\s+"
        $obj = [PSCustomObject]@{
            Section     = $section
            Destination = $columns[0]
            Gateway     = $columns[1]
            Flags       = $columns[2]
            Netif       = $columns[3]
            Expire      = if ($columns.Length -gt 4) { $columns[4] } else { $null }
        }
        
        $obj
    }

    return $data
}