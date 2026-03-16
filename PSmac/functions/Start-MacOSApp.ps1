function Start-MacOSApp { 
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateScript(
            { $_ -in (Get-ChildItem -Path @("/Applications", "~/Applications") -Filter *.app | Select-Object   @{l = "Name"; e = { $_.name.Replace('.app', '') } }).Name },
            ErrorMessage = 'Please specify the name of a subdirectory in the current directory.'
        )]
        [ArgumentCompleter(
            {
                param($cmd, $param, $wordToComplete)
                # This is the duplicated part of the code in the [ValidateScipt] attribute.
                [array] $validValues = (Get-ChildItem -Path @("/Applications", "~/Applications") -Filter *.app | Select-Object   @{l = "Name"; e = { $_.name.Replace('.app', '') } }).Name
                $validValues -like "$wordToComplete*"
            }
        )]
        [String]$AppName
    )
        
    open -a "$AppName"
}