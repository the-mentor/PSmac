function Get-MacOSNetworkInfo {
    $NetstatInfo = netstat -in
    $lines = $NetstatInfo -split "`n"

    $data = for ($i = 1; $i -lt $lines.Length; $i++) {
        $line = $lines[$i] -split "\s+"
        $obj = [PSCustomObject]@{
            Name    = $line[0]
            Mtu     = $line[1]
            Network = $line[2]
            Address = $line[3]
            Ipkts   = $line[4]
            Ierrs   = $line[5]
            Opkts   = $line[6]
            Oerrs   = $line[7]
            Coll    = $line[8]
        }
         $obj
    }

    $data
}