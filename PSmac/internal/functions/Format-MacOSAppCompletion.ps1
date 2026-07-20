function Format-MacOSAppCompletion {
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Name
    )

    process {
        if ($Name -match '\s') {
            "'$Name'"
        } else {
            $Name
        }
    }
}
