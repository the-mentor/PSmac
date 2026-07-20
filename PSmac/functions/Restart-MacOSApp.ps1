function Restart-MacOSApp { 
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateScript(
			{ $_ -in (Get-MacOSProcessName) },
			ErrorMessage = 'Please specify the name of a subdirectory in the current directory.'
		)]
		[ArgumentCompleter(
			{
				param($cmd, $param, $wordToComplete)
				[array] $validValues = Get-MacOSProcessName
				$validValues -like "$wordToComplete*" | Format-MacOSAppCompletion
			}
		)]
		[String]$AppName
	)
        
	Get-Process $AppName | Stop-Process 
	Start-Sleep -Seconds 1 
	open -a "$AppName"
}
