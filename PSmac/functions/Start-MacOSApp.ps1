function Start-MacOSApp { 
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateScript(
            { $_ -in (Get-MacOSAppName) },
            ErrorMessage = 'Please specify the name of a subdirectory in the current directory.'
        )]
        [ArgumentCompleter(
            {
                param($cmd, $param, $wordToComplete)
                [array] $validValues = Get-MacOSAppName
                $validValues -like "$wordToComplete*" | Format-MacOSAppCompletion
            }
        )]
        [String]$AppName
    )
        
    open -a "$AppName"
}